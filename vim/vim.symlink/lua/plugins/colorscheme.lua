return {
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                 style = "night",
                 dim_inactive = true,
                 on_highlights = function(hl, c)
                     hl.Normal = { fg = "#ffffff" , bg = c.bg }
                     hl.Comment = { fg = "#ffdfaf" }
                     hl.LineNr = { fg = "#ffffff", bg = "#4c4e52" }
                     hl.CursorLineNr = { fg = c.cyan, bg = "#4c4e52", bold = true }
                     hl.SignColumn = { bg = "#4c4e52" }
                     hl.DiagnosticUnnecessary = { fg = c.none, underline = true }
                     hl.WinSeparator = hl.LineNr
                 end,
            })
            vim.cmd.colorscheme("tokyonight")

            -- highlight cursorline
            vim.cmd.set("cursorline")
            vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
                command = "setlocal cursorline",
            })
            vim.api.nvim_create_autocmd("WinLeave", {
                command = "setlocal nocursorline",
            })
        end
    }
}
