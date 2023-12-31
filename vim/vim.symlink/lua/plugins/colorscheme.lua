local util = require("util")

local neon_panda_path = util.project_dir() .. "/neon-panda"
return {
    {
        dir = neon_panda_path,
        dev = true,
        priority = 1000,
        dependencies = { "rktjmp/lush.nvim" },
        config = function()
            -- add to rtp... not sure why lazy isn't automatically adding it
            vim.opt.rtp:prepend(neon_panda_path)
            vim.cmd.colorscheme("neon-panda")
        end,
    },
    {
        "folke/tokyonight.nvim",
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
            flavour = "mocha",
            no_italic = true,
            custom_highlights = function(c)
                return {
                    Visual = { fg = c.crust, bg = c.sapphire },

                    -- border
                    WinSeparator = { fg = c.surface0, bg = c.surface0 },

                    -- TSContext
                    TreesitterContext = { bg = c.surface2 },

                    -- line numbers
                    LineNr = { fg = c.subtext1, bg = c.surface0 },
                    SignColumn = { bg = c.surface0 },
                    DiagnosticSignError = { bg = c.surface0 },
                    DiagnosticSignHint = { bg = c.surface0 },
                    DiagnosticSignInfo = { bg = c.surface0 },
                    DiagnosticSignOk = { bg = c.surface0 },
                    DiagnosticSignWarn = { bg = c.surface0 },
                    CursorLine = { bg = c.surface1 },
                    CursorLineNr = { fg = c.blue, bg = c.surface1, bold = true },

                    -- types
                    Operator = { fg = c.text },
                    Constant = { fg = c.rosewater },
                    Comment = { fg = "#ffdfaf" },
                    Function = { fg = c.sapphire },
                    ["@field"] = { fg = c.teal },
                    ["@parameter"] = { fg = c.blue },
                    ["@constructor"] = { fg = c.peach, bold = true },
                    ["@type"] = { link = "@constructor" },
                    ["@function.builtin"] = { fg = c.pink },
                }
            end
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
        end,
    },
}
