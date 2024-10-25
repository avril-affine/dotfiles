vim.g.mapleader = ","

-- find correct python
vim.g.python3_host_prog = vim.fn.substitute(vim.fn.system("which python3"), "\n", "", "g")

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ruler = true -- row/col number
vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.timeoutlen = 10
vim.opt.clipboard = "unnamedplus" -- global clipboard
vim.opt.backspace = "indent,eol,start" -- fix backspace

-- relative line number *only* in current window
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
    command = "setlocal relativenumber",
})
vim.api.nvim_create_autocmd("WinLeave", {
    command = "setlocal norelativenumber",
})

-- highlight cursorline
vim.cmd.set("cursorline")
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
    command = "setlocal cursorline",
})
vim.api.nvim_create_autocmd("WinLeave", {
    command = "setlocal nocursorline",
})
