vim.g.mapleader = ","

-- find correct python
vim.g.python3_host_prog=vim.fn.substitute(vim.fn.system("which python3"), "\n", "", "g")

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ruler = true                    -- row/col number
vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.timeoutlen = 10
vim.opt.clipboard = "unnamedplus"       -- global clipboard
vim.opt.backspace = "indent,eol,start"  -- fix backspace

local function(direction):
end
