vim.g.mapleader = ","

-- find correct python
vim.g.python3_host_prog = vim.fn.substitute(vim.fn.system("which python3"), "\n", "", "g")

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.ruler = true -- row/col number
vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.timeoutlen = 10
vim.opt.clipboard = "unnamedplus" -- global clipboard
vim.opt.backspace = "indent,eol,start" -- fix backspace


vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
    callback = function()
        vim.opt_local.relativenumber = true  -- relative line number *only* in current window
        vim.opt_local.cursorline = true  -- highlight cursorline
    end,
})

vim.api.nvim_create_autocmd("WinLeave", {
    callback = function()
        vim.opt_local.relativenumber = false
        vim.opt_local.cursorline = false
    end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "*.json",
    callback = function()
        vim.opt_local.foldmethod = "expr"
        vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
        vim.opt_local.foldlevel = 2
    end,
})

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.gleam",
    callback = function()
        vim.cmd("TSBufEnable highlight")
    end,
})
