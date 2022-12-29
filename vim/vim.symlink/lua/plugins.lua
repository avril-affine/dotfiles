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

      -- COLORSCHEME -----------------------------------------------------------
      use {
        'folke/tokyonight.nvim',
        config = function()
          require('tokyonight').setup {
            style = 'night',
            dim_inactive = true,
            on_highlights = function(highlights, colors)
              highlights.Normal = { fg = colors.white, bg = colors.bg }
              highlights.Comment = { fg = '#ffdfaf' }
              highlights.LineNr = { fg = colors.white, bg = '#4c4e52' }
              highlights.CursorLineNr = { fg = colors.cyan }
              highlights.SignColumn = { bg = '#4c4e52' }
            end,
          }
          vim.cmd('colorscheme tokyonight')
        end
      }

      -- PYTHON ----------------------------------------------------------------
      use {
        'wookayin/semshi',
        ft = 'python',
      }
      use {
        'psf/black',
        ft = 'python',
      }
      use {
        'stsewd/isort.nvim',
        ft = 'python',
      }

      -- LSP / completion ------------------------------------------------------
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
            buf_set_keymap('n', '[e', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
            buf_set_keymap('n', ']e', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
            buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)

            -- buf_set_keymap('n', '<leader>D', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
            -- buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
            -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
            -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
            -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
            -- buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
            -- buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
          end

          -- LSP: python
          require('lspconfig').pylsp.setup {
            on_attach=on_attach,
            plugins = {
              pycodestyle = { enabled = false },
              pyflakes = { enabled = false },
              mccabe = { enabled = false },
              yapf = { enabled = false },
              rope_completion = {
                enabled = true,
                eager = true,
              },
            },
          }

          -- LSP: lua
          local sumneko_binary_path = vim.fn.resolve(vim.fn.exepath('lua-language-server'))
          local sumneko_root_path = vim.fn.fnamemodify(sumneko_binary_path, ':h:h')
          local runtime_path = vim.split(package.path, ';')
          table.insert(runtime_path, 'lua/?.lua')
          table.insert(runtime_path, 'lua/?/init.lua')
          require('lspconfig').sumneko_lua.setup {
            on_attach = on_attach,
            cmd = {sumneko_binary_path, '-E', sumneko_root_path .. '/main.lua'},
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

          -- LSP: dart
          local dart_binary_path = vim.fn.resolve(vim.fn.exepath('dart'))
          local dart_root_path = vim.fn.fnamemodify(dart_binary_path, ':h')
          if string.find(dart_binary_path, 'flutter') then
            dart_root_path = dart_root_path .. '/cache/dart-sdk/bin'
          end
          require('lspconfig').dartls.setup {
            on_attach = on_attach,
            cmd = { dart_binary_path, dart_root_path .. '/snapshots/analysis_server.dart.snapshot', '--lsp' },
          }

          -- LSP: rust
          local rust_analyzer_binary_path = vim.fn.resolve(vim.fn.exepath('rust-analyzer'))
          require('lspconfig').rust_analyzer.setup {
            on_attach = on_attach,
          }

          -- LSP: typescript
          require('lspconfig').tsserver.setup {
            on_attach = on_attach,
          }
        end
      }
      use {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        requires = { "neovim/nvim-lspconfig" },
        config = function()
          require("lsp_lines").setup()
          vim.diagnostic.config({
            virtual_text = false,
          })
          vim.api.nvim_set_keymap('n', '<leader>l', '<cmd>lua require("lsp_lines").toggle()<CR>', { nowait = true, silent = true })
        end,
      }
      use {
        'dart-lang/dart-vim-plugin',
        requires = { 'neovim/nvim-lspconfig' },
      }
      use {
        'simrat39/rust-tools.nvim',
        config = function()
          vim.cmd([[ autocmd BufWritePre *.rs lua vim.lsp.buf.formatting_sync(nil, 200) ]])
          require('rust-tools').setup {
            tools = { -- rust-tools options
              autoSetHints = true,
              inlay_hints = {
                  show_parameter_hints = false,
                  parameter_hints_prefix = "",
                  other_hints_prefix = "",
              },
            },

            -- all the opts to send to nvim-lspconfig
            -- these override the defaults set by rust-tools.nvim
            -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
            server = {
              -- on_attach is a callback called when the language server attachs to the buffer
              -- on_attach = on_attach,
              settings = {
                -- to enable rust-analyzer settings visit:
                -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
                ["rust-analyzer"] = {
                  -- enable clippy on save
                  checkOnSave = {
                      command = "clippy"
                  },
                }
              }
            },
        }
        end,
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
              border = "rounded", -- the border option is the same as `|help nvim_open_win|`
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
          vim.api.nvim_set_keymap("i", "<C-d>", "compe#scroll({ 'delta': +4 })", {expr = true})
          vim.api.nvim_set_keymap("i", "<C-u>", "compe#scroll({ 'delta': -4 })", {expr = true})

          -- function signature
          require "lsp_signature".setup({
            bind = true, -- This is mandatory, otherwise border config won't get registered.
            handler_opts = {
              border = "rounded",
            }
          })
        end
      }
      use {
        'nvim-treesitter/nvim-treesitter',
        requires = { 'nvim-treesitter/nvim-treesitter-textobjects', 'nvim-treesitter/playground' },
        run = ':TSUpdate',
        config = function()
          require('nvim-treesitter.configs').setup {
            ensure_installed = { 'lua', 'javascript', 'typescript', 'python', 'dart', 'rust' },  -- can specify "all"
            -- highlights
            highlight = {
              enable = true,
              disable = { 'python' },
            },
            -- text objects
            textobjects = {
              select = {
                enable = true,

                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,

                keymaps = {
                  -- You can use the capture groups defined in textobjects.scm
                  ["af"] = "@function.outer",
                  ["if"] = "@function.inner",
                  ["ac"] = "@class.outer",
                  ["ic"] = "@class.inner",
                },
              },
              move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                goto_next_start = {
                  ["]m"] = "@function.outer",
                  ["]]"] = "@class.outer",
                },
                goto_next_end = {
                  ["]M"] = "@function.outer",
                  ["]["] = "@class.outer",
                },
                goto_previous_start = {
                  ["[m"] = "@function.outer",
                  ["[["] = "@class.outer",
                },
                goto_previous_end = {
                  ["[M"] = "@function.outer",
                  ["[]"] = "@class.outer",
                },
              },
            },
            query_linter = {
              enable = true,
              use_virtual_text = true,
              lint_events = {"BufWrite", "CursorHold"},
            },
            -- playground
            playground = {
              enable = true,
              disable = {},
              updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
              persist_queries = false, -- Whether the query persists across vim sessions
              keybindings = {
                toggle_query_editor = 'o',
                toggle_hl_groups = 'i',
                toggle_injected_languages = 't',
                toggle_anonymous_nodes = 'a',
                toggle_language_display = 'I',
                focus_language = 'f',
                unfocus_language = 'F',
                update = 'R',
                goto_node = '<cr>',
                show_help = '?',
              },
            },
          }
        end,
      }

      -- NAVIGATION ------------------------------------------------------------
      use {
        'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' },
        config = function()
          vim.api.nvim_set_keymap('n', '<leader>f', '<cmd>lua require("telescope.builtin").live_grep()<CR>', { nowait = true, silent = true })
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
              },
              yank_history = {
                picker = {
                  select = {
                  action = nil, -- nil to use default put action
                  },
                  telescope = {
                    mappings = nil, -- nil to use default mappings
                  },
                },
              }
            }
          }
          require('telescope').load_extension('fzf')
        end,
      }
      use {
        'kyazdani42/nvim-tree.lua',
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = function()
          require'nvim-tree'.setup {
          }
          vim.api.nvim_set_keymap('n', '<leader>k', ':NvimTreeToggle<CR>', { nowait = true, silent = true })
        end,
      }

      -- UTILS -----------------------------------------------------------------
      use {
        'junegunn/fzf.vim',
        requires = { 'junegunn/fzf', run = 'fzf#install()' }
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
      use {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
          require("indent_blankline").setup {
            space_char_blankline = " ",
            show_current_context = true,
          }
        end
      }
      use {
        "karb94/neoscroll.nvim",
        config = function()
          local t = {}
          t['<C-u>'] = {'scroll', {'-vim.wo.scroll', 'true', '75'}}
          t['<C-d>'] = {'scroll', { 'vim.wo.scroll', 'true', '75'}}

          require('neoscroll').setup({
            mappings = { '<C-u>', '<C-d>' },
          })
          require('neoscroll.config').set_mappings(t)
        end
      }
      use {
        "gbprod/yanky.nvim",
        requires = { "nvim-telescope/telescope.nvim" },
        config = function()
          local utils = require("yanky.utils")
          local mapping = require("yanky.telescope.mapping")
          require("yanky").setup {
            ring = {
              history_length = 100,
              storage = "shada",
              sync_with_numbered_registers = true,
              cancel_event = "update",
            },
            picker = {
              telescope = {
                mappings = {
                  default = mapping.set_register(utils.get_default_register()),
                  i = {
                    ["<c-p>"] = mapping.put("p"),
                    ["<c-k>"] = mapping.put("P"),
                    ["<c-x>"] = mapping.delete(),
                    ["<c-y>"] = mapping.set_register(utils.get_default_register()),
                  },
                  n = {
                    p = mapping.put("p"),
                    P = mapping.put("P"),
                    d = mapping.delete(),
                    y = mapping.set_register(utils.get_default_register()),
                  },
                }
              }
            },
            system_clipboard = {
              sync_with_ring = true,
            },
          }

          require("telescope").load_extension("yank_history")
          vim.api.nvim_set_keymap("n", "<leader>y", "<cmd>Telescope yank_history<CR>", {})
        end
      }
      use {
        'kdheepak/lazygit.nvim',
        config = function()
          vim.api.nvim_set_keymap('n', '<leader>g', ':LazyGit<CR>', { nowait = true, silent = true })
        end,
      }
      use { 'tpope/vim-fugitive' }
      use {
        'ruanyl/vim-gh-line',
        config = function() vim.g.gh_line_blame_map = '<leader>b' end,
      }
      use {
        'folke/todo-comments.nvim',
        requires = { 'nvim-lua/plenary.nvim' },
        config = function()
          require('todo-comments').setup {
              -- your configuration comes here
              -- or leave it empty to use the default settings
              -- refer to the configuration section below
          }
        end,
      }
  end,
  config = {
    package_root = package_root,
    compile_path = install_path .. '/plugin/packer_compiled.lua',
  },
}
