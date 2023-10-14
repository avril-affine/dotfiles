-- relative line number *only* in current window
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
    command = "setlocal relativenumber",
})
vim.api.nvim_create_autocmd("WinLeave", {
    command = "setlocal norelativenumber",
})
-- FIXME: REMOVE DEBUG
-- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, { callback = vim.lsp.buf.document_highlight })
-- autocmd({ "CursorMoved" }, { callback = vim.lsp.buf.clear_references })
--
vim.lsp.set_log_level("debug")
