local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- turn off lsp_lines by default
-- autocmd("VimEnter", { callback = function() require("lsp_lines").toggle() end })


-- vim.api.nvim_set_hl(0, "CursorLine", { cterm = { underline = true } })
-- augroup("CursorLine", { clear = true })
-- autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
--     group = "CursorLine",
--     command = "setlocal cursorline",
-- })
-- autocmd("WinLeave", {
--     group = "CursorLine",
--     command = "setlocal nocursorline",
-- })

-- relative line number *only* in current window
autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
    command = "setlocal relativenumber",
})
autocmd("WinLeave", {
    command = "setlocal norelativenumber",
})
