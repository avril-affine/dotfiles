local autocmd = vim.api.nvim_create_autocmd

-- relative line number *only* in current window
autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
    command = "setlocal relativenumber",
})
autocmd("WinLeave", {
    command = "setlocal norelativenumber",
})
