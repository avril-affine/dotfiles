return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		init = function()
            local actions = require("telescope.actions")
			require("telescope").setup({
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "respect_case",
					},
				},
                defaults = {
                    mappings = {
                        n  = {
                            ["<leader>qf"] = actions.send_selected_to_qflist + actions.open_qflist,
                            ["<leader>qF"] = actions.smart_send_to_qflist + actions.open_qflist,
                        },
                    },
                },
			})
		end,
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		build = "make",
		init = function()
			require("telescope").load_extension("fzf")
		end,
	},
	{
		"stevearc/oil.nvim",
        lazy = false,
        keys = {
            { "<leader>k", function() require("oil").open_float() end },
        },
		init = function()
			require("oil").setup({
				columns = {
					"icon",
					"permissions",
					"size",
					"mtime",
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "nvim-treesitter/nvim-treesitter-context",
            "nvim-treesitter/playground",
        },
		build = ":TSUpdate",
		opts = {
            ensure_installed = {
                "bash",
                "html",
                "json",
                "luadoc",
                "markdown",
                "python",
                "regex",
                "tsx",
                "vim",
                "yaml",
                "c",
                "javascript",
                "lua",
                "luap",
                "markdown_inline",
                "query",
                "rust",
                "typescript",
                "vimdoc",
            },
            -- highlights
            highlight = {
                enable = true,
                disable = { "python" },
            },
            query_linter = {
                enable = true,
                use_virtual_text = true,
                lint_events = { "BufWrite", "CursorHold" },
            },
            -- text objects
            textobjects = {
                select = {
                    enable = true,

                    -- Automatically jump forward to textobj, similar to targets.vim
                    lookahead = true,

                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        ["]m"] = "@function.outer",
                        ["]]"] = "@class.outer",
                    },
                    goto_next_end = {
                        ["]M"] = "@function.outer",
                        ["]["] = "@class.outer",
                    },
                    goto_previous_start = {
                        ["[m"] = "@function.outer",
                        ["[["] = "@class.outer",
                    },
                    goto_previous_end = {
                        ["[M"] = "@function.outer",
                        ["[]"] = "@class.outer",
                    },
                },
            },
            -- context
            context = {
                multiline_threshold = 80,
            },
            -- playground
            playground = {
                enable = true,
                disable = {},
                updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
                persist_queries = false, -- Whether the query persists across vim sessions
                keybindings = {
                    toggle_query_editor = "o",
                    toggle_hl_groups = "i",
                    toggle_injected_languages = "t",
                    toggle_anonymous_nodes = "a",
                    toggle_language_display = "I",
                    focus_language = "f",
                    unfocus_language = "F",
                    update = "R",
                    goto_node = "<cr>",
                    show_help = "?",
                },
            },
        }
	},
	{
		"machakann/vim-swap",
	},
    {
        "echasnovski/mini.surround",
        keys = function(_, keys)
            -- Populate the keys based on the user's options
            local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
            local opts = require("lazy.core.plugin").values(plugin, "opts", false)
            local mappings = {
                { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
                { opts.mappings.delete, desc = "Delete surrounding" },
                { opts.mappings.find, desc = "Find right surrounding" },
                { opts.mappings.find_left, desc = "Find left surrounding" },
                { opts.mappings.replace, desc = "Replace surrounding" },
            }
            mappings = vim.tbl_filter(function(m)
                return m[1] and #m[1] > 0
            end, mappings)
            return vim.list_extend(mappings, keys)
        end,
        opts = {
            mappings = {
                add = "Sa", -- Add surrounding in Normal and Visual modes
                delete = "Sd", -- Delete surrounding
                find = "Sf", -- Find surrounding (to the right)
                find_left = "SF", -- Find surrounding (to the left)
                replace = "Sr", -- Replace surrounding
            },
        },
    },
    {
        "echasnovski/mini.bufremove",
        keys = {
            { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "Delete Buffer" },
        },
    },
    {
        "stevearc/aerial.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            { "<leader>a", "<cmd>AerialToggle!<CR>", desc = "AerialToggle" },
            { "{", "<cmd>AerialPrev<CR>", desc = "AerialPrev" },
            { "}", "<cmd>AerialNext<CR>", desc = "AerialNext" },
        },
        opts = {
            backends = { "treesitter" },
            default_direction = { "prefer_right" },
        },
    },
    {
        "sindrets/diffview.nvim",
    },

    -- bufferline
    {
        "akinsho/bufferline.nvim",
        dependencies = {
            "LazyVim/LazyVim",
            "nvim-tree/nvim-web-devicons",
        },
        event = "VeryLazy",
        keys = {
            { "<leader>bb", "<cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
            { "<leader>bD", "<cmd>BufferLineCloseRight<CR>", desc = "Delete all buffers to the right" },
            { "<leader>bn", "<cmd>BufferLineCycleNext<CR>", desc = "move to next buffer" },
            { "<leader>bp", "<cmd>bBufferLineCyclePrevious<CR>", desc = "move to previous buffer" },
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
                right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
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
                hint_selected = { fg = "NONE", underline = true, italic = false },
                info_selected = { fg = "NONE", underline = true, italic = false },
                warning_selected = { fg = "NONE", underline = true,  italic = false },
                error_selected = { fg = "NONE", underline = true, italic = false },
                warning_diagnostic_selected = { italic = false },
                hint_diagnostic_selected = { italic = false },
                info_diagnostic_selected = { italic = false },
                diagnostic_selected = { italic = false },
                error_diagnostic_selected = { italic = false },
                numbers_selected  = { underline = false },
                diagnostic_selected = { underline = false },
            }
        end,
    },

}
