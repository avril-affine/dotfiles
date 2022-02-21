vim.opt.packpath = '~/.config/nvim/site'

local package_root = vim.fn.expand('~/.config/nvim/site/pack')
local install_path = package_root .. '/packer/start/packer.nvim'
local fn = vim.fn
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require('packer').startup {
  function(use)
    local packer = require('packer')
    local use = packer.use
      use { 'wbthomason/packer.nvim' }

      -- python
      use {
        'numirias/semshi',
        ft = 'python',
        config = 'vim.cmd [[UpdateRemotePlugins]]',
      }
      use {
        'psf/black',
        ft = 'python',
        config = 'vim.cmd [[UpdateRemotePlugins]]',
      } 
      use {
        'stsewd/isort.nvim',
        ft = 'python',
        config = 'vim.cmd [[UpdateRemotePlugins]]',
      }

      -- LSP / completion
      use {
        'neovim/nvim-lspconfig',
        config = function()
          -- LSP
          -- TODO: Why do I define on_attach here?
          local on_attach = function(_, bufnr)
            local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
            local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

            buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

            -- LSP: mappings
            local opts = { noremap = true, silent = true }

            buf_set_keymap('n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
            buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
            buf_set_keymap('n', '<leader>i', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
            buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
            buf_set_keymap('n', '<leader>r', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
            buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
            buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
            buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)

            -- buf_set_keymap('n', '<leader>D', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
            -- buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
            -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
            -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
            -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
            -- buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
            -- buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
          end

          -- LSP: pyright
          require('lspconfig').pyright.setup { on_attach=on_attach }

          -- LSP: sumneko_lua
          local sumneko_binary_path = vim.fn.exepath('lua-language-server')
          local sumneko_root_path = vim.fn.fnamemodify(sumneko_binary_path, ':h:h:h')
          local runtime_path = vim.split(package.path, ';')
          table.insert(runtime_path, 'lua/?.lua')
          table.insert(runtime_path, 'lua/?/init.lua')
          require('lspconfig').sumneko_lua.setup {
            on_attach = on_attach,
            cmd = {sumneko_binary_path, '-E', sumneko_root_path .. '/main.lua'};
            settings = {
                Lua = {
                  runtime = {
                      version = 'LuaJIT',
                      path = runtime_path,
                  },
                  diagnostics = {
                      -- Get the language server to recognize the `vim` global
                      globals = {'vim'},
                  },
                  workspace = {
                      -- Make the server aware of Neovim runtime files
                      library = vim.api.nvim_get_runtime_file('', true),
                  },
                  -- Do not send telemetry data containing a randomized but unique identifier
                  telemetry = {
                      enable = false,
                  },
                },
            },
          }

        end
      }
      use {
        'hrsh7th/nvim-compe',
        requires = {
          { 'hrsh7th/vim-vsnip' },
          { 'ray-x/lsp_signature.nvim' },
        },
        config = function()
          require('compe').setup {
            enabled = true;
            autocomplete = true;
            debug = false;
            min_length = 1;
            preselect = 'enable';
            throttle_time = 80;
            source_timeout = 200;
            resolve_timeout = 800;
            incomplete_delay = 400;
            max_abbr_width = 100;
            max_kind_width = 100;
            max_menu_width = 100;
            documentation = {
              border = { '', '' ,'', ' ', '', '', '', ' ' }, -- the border option is the same as `|help nvim_open_win|`
              winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
              max_width = 120,
              min_width = 60,
              max_height = math.floor(vim.o.lines * 0.3),
              min_height = 1,
            };

            source = {
              path = true;
              buffer = true;
              calc = true;
              nvim_lsp = true;
              nvim_lua = true;
              vsnip = true;
              ultisnips = true;
              luasnip = true;
            };
          }

          -- tab completion
          local t = function(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end

          local check_back_space = function()
              local col = vim.fn.col('.') - 1
              return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
          end

          -- Use (s-)tab to:
          --- move to prev/next item in completion menuone
          --- jump to prev/next snippet's placeholder
          _G.tab_complete = function()
            if vim.fn.pumvisible() == 1 then
              return t "<C-n>"
            elseif vim.fn['vsnip#available'](1) == 1 then
              return t "<Plug>(vsnip-expand-or-jump)"
            elseif check_back_space() then
              return t "<Tab>"
            else
              return vim.fn['compe#complete']()
            end
          end
          _G.s_tab_complete = function()
            if vim.fn.pumvisible() == 1 then
              return t "<C-p>"
            elseif vim.fn['vsnip#jumpable'](-1) == 1 then
              return t "<Plug>(vsnip-jump-prev)"
            else
              -- If <S-Tab> is not working in your terminal, change it to <C-h>
              return t "<S-Tab>"
            end
          end

          vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
          vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
          vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
          vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

          -- function signature
          require('lsp_signature').setup()
        end
      }
      use {
        'folke/trouble.nvim',
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = function()
          require('trouble').setup {
            vim.api.nvim_set_keymap('n', '<leader>t', ':TroubleToggle<CR>', { nowait = true })
          }
        end,
      }
      use {
        'nvim-treesitter/nvim-treesitter',
        config = function()
          require'nvim-treesitter.configs'.setup {
            ensure_installed = { 'lua', 'javascript' },  -- can specify "all"
            highlight = {
              enable = true,
              disable = { 'python' },
            },
          }
        end,
      }

      -- navigation
      use {
        'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' },
        config = function()

          vim.api.nvim_set_keymap('n', '<leader>f', '"zyiw<cmd>lua require("telescope.builtin").live_grep()<CR> <ESC>"zpa', { nowait = true, silent = true })
          vim.api.nvim_set_keymap('n', '<C-P>', '<cmd>lua require("telescope.builtin").find_files()<CR>', { nowait = true, silent = true })
        end,
      }
      use {
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make',
        config = function()
          require('telescope').setup {
            extensions = {
              fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = 'respect_case',
              }
            }
          }
          require('telescope').load_extension('fzf') end,
      }
      use {
        'kyazdani42/nvim-tree.lua',
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = function()
          require'nvim-tree'.setup {
          }
          vim.api.nvim_set_keymap('n', '<leader>k', ':NvimTreeToggle<CR>', { nowait = true })
        end,
      }
      use {
        'kdheepak/lazygit.nvim',
        config = function()
          vim.api.nvim_set_keymap('n', '<leader>l', ':LazyGit<CR>', { nowait = true })
        end,
      }
      use { 'tpope/vim-fugitive' }
      use {
        'ruanyl/vim-gh-line',
        config = function() vim.g.gh_line_blame_map = '<leader>g' end,
      }
      use {
        'folke/todo-comments.nvim',
        requires = { 'nvim-lua/plenary.nvim' },
        -- 
        config = function()
          require('todo-comments').setup {
              -- your configuration comes here
              -- or leave it empty to use the default settings
              -- refer to the configuration section below
          }
        end,
      }

      -- utils
      use {
        'junegunn/fzf.vim',
        requires = { 'junegunn/fzf', run = 'fzf#install()' }
      }
      use {
        'terryma/vim-smooth-scroll',
        config = function()
          vim.api.nvim_set_keymap('n', '<C-U>', ':call smooth_scroll#up(&scroll, 0, 3)<CR>', { nowait = true, silent = true })
          vim.api.nvim_set_keymap('n',  '<C-D>', ':call smooth_scroll#down(&scroll, 0, 3)<CR>', { nowait = true, silent = true })
        end,
      }

      use { 'machakann/vim-swap' }
      use {
        'hoob3rt/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true, },
        config = function()
          require('plenary.reload').reload_module('lualine', true)
          require'lualine'.setup {
            options = {
              icons_enabled = true,
              theme = 'OceanicNext',  -- other themes: 'material' 'onedark'
              component_separators = {'', '|'},
              section_separators = {'', ''},
              disabled_filetypes = {}
            },
            sections = {
              lualine_a = {'mode'},
              lualine_b = {'branch'},
              lualine_c = {{
                'filename',
                file_status = true,
                path = 2,  -- absolute path
              }},
              lualine_x = {'encoding', 'fileformat', 'filetype'},
              lualine_y = {'progress'},
              lualine_z = {'location'}
            },
            inactive_sections = {
              lualine_a = {},
              lualine_b = {'branch'},
              lualine_c = {'filename'},
              lualine_x = {'location'},
              lualine_y = {},
              lualine_z = {}
            },
            tabline = {},
            extensions = {},
          }
        end
      }
      use {
        'yamatsum/nvim-nonicons',
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = function() require('nvim-nonicons').get('file') end,
      }
  end,
  config = {
    package_root = package_root,
    compile_path = install_path .. '/plugin/packer_compiled.lua',
  },
}
