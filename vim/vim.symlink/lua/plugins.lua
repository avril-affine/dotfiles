vim.cmd [[set runtimepath=$VIMRUNTIME]]
vim.cmd [[set packpath=/tmp/nvim/site]]

local package_root = '/tmp/nvim/site/pack'
local install_path = package_root .. '/packer/start/packer.nvim'

-- FIXME: am i using config properly
local function load_plugins()
  local packer = require('packer')
  local use = packer.use
  require('packer').startup ({function()
    use 'wbthomason/packer.nvim'

    -- python
    use { 'numirias/semshi', ft = 'python', config = 'vim.cmd [[UpdateRemotePlugins]]' }

    -- LSP / completion
    use { 'neovim/nvim-lspconfig', lock = true }
    use { 'nvim-lua/completion-nvim', lock = true }
    use {
      'folke/trouble.nvim',
      requires = { 'kyazdani42/nvim-web-devicons' },
      config = function()
        require('trouble').setup {
          -- your configuration comes here
          -- or leave it empty to use the default settings
          -- refer to the configuration section below
        }
      end,
      lock = true,
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
      lock = true,
    }

    -- file utils
    use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' }, lock = true }
    use {
      'nvim-telescope/telescope-fzf-native.nvim',
      run = 'make',
      config = function()
        require('telescope').setup {
          case_mode = 'respect_case'
        }
      end,
      lock = true,
    }

    use {
      'kyazdani42/nvim-tree.lua',
      requires = { 'kyazdani42/nvim-web-devicons' },
      config = function()
        require'nvim-tree'.setup {
        }
        vim.api.nvim_set_keymap('n', '<leader>k', ':NvimTreeToggle<CR>', { nowait = true })
      end,
      lock = true,
    }
    use {
      'kdheepak/lazygit.nvim',
      config = function()
        vim.api.nvim_set_keymap('n', '<leader>l', ':LazyGit<CR>', { nowait = true })
      end,
      lock = true,
    }
    use { 'tpope/vim-fugitive', lock = true }
    use { 'ruanyl/vim-gh-line', lock = true }

    -- utils
    use { 'terryma/vim-smooth-scroll', lock = true }
    use { 'machakann/vim-swap', lock = true }
    use {
      'hoob3rt/lualine.nvim',
      requires = {'kyazdani42/nvim-web-devicons', opt = true},
      lock = true,
    }
    use {
      'yamatsum/nvim-nonicons',
      requires = {'kyazdani42/nvim-web-devicons'},
      config = function()
        require('nvim-nonicons').get('file')
      end,
    }

    end,
    config = {
      package_root = package_root,
      compile_path = install_path .. '/plugin/packer_compiled.lua',
    }
	})
end

_G.load_config = function()
  -- LSP
  local lspconfig = require('lspconfig')
  -- TODO: Why do I define on_attach here?
  local on_attach = function(_, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
	  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- LSP: mappings
    local opts = { noremap = true, silent = true }

    buf_set_keymap('n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', '<leader>i', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts) buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<leader>r', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)

    -- buf_set_keymap('n', '<leader>D', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    -- buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    -- buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    -- buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    -- buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  end

  -- LSP: pyright
  lspconfig.pyright.setup { on_attach=on_attach }

  -- LSP: sumneko_lua
  local sumneko_binary_path = vim.fn.exepath('lua-language-server')
  local sumneko_root_path = vim.fn.fnamemodify(sumneko_binary_path, ':h:h:h')
  local runtime_path = vim.split(package.path, ';')
  table.insert(runtime_path, 'lua/?.lua')
  table.insert(runtime_path, 'lua/?/init.lua')
  require'lspconfig'.sumneko_lua.setup {
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

  local opts = { noremap = true, silent = true }
  -- smooth scroll
  vim.api.nvim_set_keymap('n', '<C-U>', ':call smooth_scroll#up(&scroll, 0, 3)<CR>', opts)
  vim.api.nvim_set_keymap('n',  '<C-D>', ':call smooth_scroll#down(&scroll, 0, 3)<CR>', opts)

  -- telescope
  vim.api.nvim_set_keymap('n', '<leader>f', '<cmd>lua require("telescope.builtin").live_grep()<CR>', opts)
  vim.api.nvim_set_keymap('n', '<C-P>', '<cmd>lua require("telescope.builtin").find_files()<CR>', opts)
  require('telescope').setup {
    fuzzy = true,
    override_generic_sorter = true,
    override_file_sorter = true,
    case_mode = 'respect_case',
  }
  require('telescope').load_extension('fzf')

  -- lualine
  require('plenary.reload').reload_module('lualine', true)
  require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'gruvbox',
    component_separators = {'', ''},
    section_separators = {'', ''},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = {'filename'},
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
  extensions = {}
  }

  -- ghline
  vim.g.gh_line_blame_map = '<leader>g'

  -- todo-comments

end

local function startup()
  if vim.fn.isdirectory(install_path) == 0 then
    vim.fn.system { 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path }
    load_plugins()
    require('packer').sync()
    vim.cmd [[autocmd User PackerComplete ++once lua load_config()]]
  else
    load_plugins()
    require('packer').sync()
    _G.load_config()
  end
end

return {startup = startup}