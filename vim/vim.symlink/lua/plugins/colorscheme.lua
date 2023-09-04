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

            -- highlight cursorline
            vim.cmd.set("cursorline")
            vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
                command = "setlocal cursorline",
            })
            vim.api.nvim_create_autocmd("WinLeave", {
                command = "setlocal nocursorline",
            })
        end
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            no_italic = true,
            -- color_overrides = {
			-- 	mocha = {
			-- 		base = "#000000",
			-- 		mantle = "#000000",
			-- 		crust = "#000000",
			-- 	},
			-- },
            custom_highlights = function (c)
                return {
                    LineNr = { fg = "#fffff0" },
                    Comment = { fg = "#ffdfaf" },
                    CursorLineNr = { fg = "#39ff00", bold = true },
                }
            end
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd.colorscheme("catppuccin")
        end,
    },
}
