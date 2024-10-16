return {
    -- {
    --     "karb94/neoscroll.nvim",
    --     config = function()
    --         require("neoscroll").setup({
    --             mappings = { "<C-u>", "<C-d>" },
    --         })
    --         require("neoscroll.config").set_mappings({
    --             ["<C-u>"] = {"scroll", {"-vim.wo.scroll", "true", "75"}},
    --             ["<C-d>"] = {"scroll", { "vim.wo.scroll", "true", "75"}},
    --         })
    --     end,
    -- },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
    },
    -- Better `vim.notify()`
    {
        "rcarriga/nvim-notify",
        opts = {
            timeout = 3000,
            max_height = function()
                return math.floor(vim.o.lines * 0.75)
            end,
            max_width = function()
                return math.floor(vim.o.columns * 0.75)
            end,
        },
    },

    -- statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "LazyVim/LazyVim",
            "folke/noice.nvim",
        },
        event = "VeryLazy",
        opts = function()
            local icons = require("lazyvim.config").icons
            local ui = require("lazyvim.util").ui

            return {
                options = {
                    theme = "auto",
                    globalstatus = true,
                    disabled_filetypes = { statusline = { "dashboard", "alpha" } },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch" },
                    lualine_c = {
                        {
                            "diagnostics",
                            symbols = {
                                error = icons.diagnostics.Error,
                                warn = icons.diagnostics.Warn,
                                info = icons.diagnostics.Info,
                                hint = icons.diagnostics.Hint,
                            },
                        },
                        { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
                        { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
                        -- stylua: ignore
                        {
                            function() return require("nvim-navic").get_location() end,
                            cond = function() return package.loaded["nvim-navic"] and require("nvim-navic").is_available() end,
                        },
                    },
                    lualine_x = {
                        -- stylua: ignore
                        {
                            function() return require("noice").api.status.command.get() end,
                            cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
                            color = ui.fg("Statement"),
                        },
                        -- stylua: ignore
                        {
                            function() return require("noice").api.status.mode.get() end,
                            cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
                            color = ui.fg("Constant"),
                        },
                        -- stylua: ignore
                        {
                            function() return "  " .. require("dap").status() end,
                            cond = function () return package.loaded["dap"] and require("dap").status() ~= "" end,
                            color = ui.fg("Debug"),
                        },
                        { require("lazy.status").updates, cond = require("lazy.status").has_updates, color = ui.fg("Special") },
                        {
                            "diff",
                            symbols = {
                                added = icons.git.added,
                                modified = icons.git.modified,
                                removed = icons.git.removed,
                            },
                        },
                    },
                    lualine_y = {
                        { "progress", separator = " ", padding = { left = 1, right = 0 } },
                        { "location", padding = { left = 0, right = 1 } },
                    },
                    lualine_z = {
                        function()
                            return " " .. os.date("%R")
                        end,
                    },
                },
                extensions = { "neo-tree", "lazy" },
            }
        end,
    },

    -- indent guides for Neovim
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            indent = {
                char = "▎",
            },
            scope = {
                enabled = false,
            },
            whitespace = {
                remove_blankline_trail = false,
            },
            exclude = {
                filetypes = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
            },
        },
    },

    -- active indent guide and indent text objects
    {
        "echasnovski/mini.indentscope",
        version = false, -- wait till new 0.7.0 release to put it back on semver
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            -- symbol = "▏",
            symbol = "│",
            options = { try_as_border = true },
        },
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
                callback = function()
                    vim.b.miniindentscope_disable = true
                end,
            })
        end,
    },
    -- colors
    {
        "echasnovski/mini.colors",
    },
    -- dashboard
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        opts = function()
            local dashboard = require("alpha.themes.dashboard")
            local logo = [[
            ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
            ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z    
            ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z       
            ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z         
            ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
            ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
            ]]

            dashboard.section.header.val = vim.split(logo, "\n")
            dashboard.section.buttons.val = {
                dashboard.button("f", " " .. " Find file", ":Telescope find_files <CR>"),
                dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
                dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
                dashboard.button("g", " " .. " Find text", ":Telescope live_grep <CR>"),
                dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"),
                dashboard.button("s", " " .. " Restore Session", [[:lua require("persistence").load() <cr>]]),
                dashboard.button("l", "󰒲 " .. " Lazy", ":Lazy<CR>"),
                dashboard.button("q", " " .. " Quit", ":qa<CR>"),
            }
            for _, button in ipairs(dashboard.section.buttons.val) do
                button.opts.hl = "AlphaButtons"
                button.opts.hl_shortcut = "AlphaShortcut"
            end
            dashboard.section.header.opts.hl = "AlphaHeader"
            dashboard.section.buttons.opts.hl = "AlphaButtons"
            dashboard.section.footer.opts.hl = "AlphaFooter"
            dashboard.opts.layout[1].val = 8
            return dashboard
        end,
        config = function(_, dashboard)
            -- close Lazy and re-open when the dashboard is ready
            if vim.o.filetype == "lazy" then
                vim.cmd.close()
                vim.api.nvim_create_autocmd("User", {
                    pattern = "AlphaReady",
                    callback = function()
                        require("lazy").show()
                    end,
                })
            end

            require("alpha").setup(dashboard.opts)

            vim.api.nvim_create_autocmd("User", {
                pattern = "LazyVimStarted",
                callback = function()
                    local stats = require("lazy").stats()
                    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                    dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
                    pcall(vim.cmd.AlphaRedraw)
                end,
            })
        end,
    },

    -- icons
    { "nvim-tree/nvim-web-devicons", lazy = true },

    -- bufferline
    {
        "akinsho/bufferline.nvim",
        dependencies = {
            "LazyVim/LazyVim",
            "echasnovski/mini.bufremove",
            "nvim-tree/nvim-web-devicons",
        },
        event = "VeryLazy",
        keys = {
            { "<leader>bb", "<cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
            { "<leader>bd", "<cmd>bd<CR>", desc = "Delete current buffer" },
            { "<leader>bD", "<cmd>BufferLineCloseOthers<CR>", desc = "Delete all buffers to the right" },
            { "<leader>bn", "<cmd>BufferLineCycleNext<CR>", desc = "move to next buffer" },
            { "<leader>bN", "<cmd>BufferLineCyclePrevious<CR>", desc = "move to previous buffer" },
            { "<leader>1", "<cmd>BufferLineGoToBuffer 1<CR>", desc = "Go to buffer #" },
            { "<leader>2", "<cmd>BufferLineGoToBuffer 2<CR>", desc = "Go to buffer #" },
            { "<leader>3", "<cmd>BufferLineGoToBuffer 3<CR>", desc = "Go to buffer #" },
            { "<leader>4", "<cmd>BufferLineGoToBuffer 4<CR>", desc = "Go to buffer #" },
            { "<leader>5", "<cmd>BufferLineGoToBuffer 5<CR>", desc = "Go to buffer #" },
            { "<leader>6", "<cmd>BufferLineGoToBuffer 6<CR>", desc = "Go to buffer #" },
            { "<leader>7", "<cmd>BufferLineGoToBuffer 7<CR>", desc = "Go to buffer #" },
            { "<leader>8", "<cmd>BufferLineGoToBuffer 8<CR>", desc = "Go to buffer #" },
            { "<leader>9", "<cmd>BufferLineGoToBuffer 9<CR>", desc = "Go to buffer #" },
            { "<leader>$", "<cmd>BufferLineGoToBuffer -1<CR>", desc = "Go to buffer #" },
        },
        opts = function(_, opts)
            opts.options = {
                modified_icon = "●",
                numbers = function(o)
                    if vim.api.nvim_get_current_buf() == o.id then return "" end
                    return o.ordinal
                end,
                close_command = function(n) require("mini.bufremove").delete(n, false) end,
                diagnostics = "nvim_lsp",
                always_show_bufferline = false,
                show_buffer_icons = false,
                diagnostics_indicator = function(_, _, diag)
                    local icons = require("lazyvim.config").icons.diagnostics
                    local ret = (diag.error and icons.Error .. diag.error .. " " or "")
                    .. (diag.warning and icons.Warn .. diag.warning or "")
                    return vim.trim(ret)
                end,
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "Neo-tree",
                        highlight = "Directory",
                        text_align = "left",
                    },
                },
                separator_style = "thick",
            }
            opts.highlights = {
                buffer_selected = {
                    fg = "white",
                    bold = true,
                    underline = true,
                    italic = false,
                },
                separator = {
                    fg = { highlight = "Comment", attribute = "fg" },
                    bold = true,
                },
                separator_selected = {
                    fg = { highlight = "Comment", attribute = "fg" },
                    bold = true,
                },
                -- bufferline selected highlights
                hint_selected = { fg = "NONE", underline = true, italic = false },
                info_selected = { fg = "NONE", underline = true, italic = false },
                warning_selected = { fg = "NONE", underline = true,  italic = false },
                error_selected = { fg = "NONE", underline = true, italic = false },
                numbers_selected = { underline = true },
                warning_diagnostic_selected = { underline = true, italic = false },
                hint_diagnostic_selected = { underline = true, italic = false },
                info_diagnostic_selected = { underline = true, italic = false },
                error_diagnostic_selected = { underline = true, italic = false },
                -- diagnostic_selected = { underline = false },
            }
        end,
    },
    {
        "norcalli/nvim-colorizer.lua",
        lazy = true,
    },
}
