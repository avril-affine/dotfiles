local utils = require('utils')
require('plugins')

vim.cmd [[set runtimepath+=~/.config/nvim]]
vim.cmd [[set runtimepath+=~/.config/nvim/after]]

-- options
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ruler = true                    -- row/col number
vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.timeoutlen = 10
vim.opt.clipboard = 'unnamedplus'       -- global clipboard
vim.opt.backspace = 'indent,eol,start'  -- fix backspace

vim.opt.grepprg = 'rg --vimgrep --no-heading'  -- use ripgrep

vim.g.python3_host_prog=vim.fn.substitute(vim.fn.system('which python3'), '\n', '', 'g')  -- find correct python

-- colors are under $VIMRUNTIME/colors
vim.cmd('colorscheme panda')

-- keybindings
vim.g.mapleader = ','

local win_keyopts = { nowait = true, silent = true }

vim.api.nvim_set_keymap('n', '<C-K>', ":call WinMove('k')<CR>", win_keyopts)   -- ctrl+k move window up
vim.api.nvim_set_keymap('n', '<C-J>', ":call WinMove('j')<CR>", win_keyopts)   -- ctrl+j move window down
vim.api.nvim_set_keymap('n', '<C-H>', ":call WinMove('h')<CR>", win_keyopts)   -- ctrl+h move window left
vim.api.nvim_set_keymap('n', '<C-L>', ":call WinMove('l')<CR>", win_keyopts)   -- ctrl+l move window right

vim.api.nvim_set_keymap('i', '˚', ":resize -1<CR>", win_keyopts)            -- alt+k resize window up
vim.api.nvim_set_keymap('n', '˚', ":resize -1<CR>", win_keyopts)
vim.api.nvim_set_keymap('v', '˚', ":resize -1<CR>", win_keyopts)
vim.api.nvim_set_keymap('i', '∆', ":resize +1<CR>", win_keyopts)            -- alt+j resize window down
vim.api.nvim_set_keymap('n', '∆', ":resize +1<CR>", win_keyopts)
vim.api.nvim_set_keymap('v', '∆', ":resize +1<CR>", win_keyopts)
vim.api.nvim_set_keymap('i', '˙', ":vertical resize -1<CR>", win_keyopts)   -- alt+h resize window left
vim.api.nvim_set_keymap('n', '˙', ":vertical resize -1<CR>", win_keyopts)
vim.api.nvim_set_keymap('v', '˙', ":vertical resize -1<CR>", win_keyopts)
vim.api.nvim_set_keymap('i', '¬', ":vertical resize +1<CR>", win_keyopts)   -- alt+l resize window right
vim.api.nvim_set_keymap('n', '¬', ":vertical resize +1<CR>", win_keyopts)
vim.api.nvim_set_keymap('v', '¬', ":vertical resize +1<CR>", win_keyopts)

vim.api.nvim_set_keymap('n', '<leader>c', ':tabnew<CR>', win_keyopts)        -- create new tab
vim.api.nvim_set_keymap('n', '<leader>n', ':tabnext<CR>', win_keyopts)       -- move to next tab
vim.api.nvim_set_keymap('n', '<leader>p', ':tabprevious<CR>', win_keyopts)   -- move to previous tab

-- Underline current line
vim.cmd([[
set cursorline
hi clear CursorLine
hi CursorLine gui=underline cterm=underline
augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  au WinLeave * setlocal nocursorline
augroup END

" Relative number line in current window
augroup BgHighlight
  autocmd!
  au VimEnter,WinEnter,BufWinEnter * set relativenumber
  autocmd WinLeave * set norelativenumber
augroup END
]])

-- TODO: lua version. move to wincmd.lua?
vim.cmd([[
  function! WinMove(key)
    let t:curwin = winnr()
    exec "wincmd ".a:key
    if (t:curwin == winnr()) "we havent moved
      if (match(a:key,'[jk]')) "were we going up/down
        wincmd v
      else
        wincmd s
      endif
      exec "wincmd ".a:key
    endif
  endfunction
]])

vim.cmd([[
  if executable('rg')
    " Use rg over grep
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case

    " bind \ (backward slash) to grep shortcut
    command -nargs=+ -complete=file -bar Rg silent! grep! <args>|cwindow|redraw!
    nnoremap \ :Rg<SPACE>
  endif

  nnoremap <leader>q :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>
]])

-- autocompile packer
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])
