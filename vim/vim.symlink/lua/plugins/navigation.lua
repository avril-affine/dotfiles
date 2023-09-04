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
        lazy = false,
        keys = {
            { "<leader>sa", desc = "Add surrounding", mode = { "n", "v" } },
            { "<leader>sd", desc = "Delete surrounding", mode = { "n", "v" } },
            { "<leader>ss", desc = "Replace surrounding", mode = { "n", "v" } },
        },
        opts = {
            mappings = {
                add = "<leader>sa",
                delete = "<leader>sd",
                replace = "<leader>ss",
            },
        },
    },
    {
        "stevearc/aerial.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            { "<leader>a", "<cmd>AerialToggle!<CR>", desc = "Navigate blocks side pane" },
            { "<leader>A", "<cmd>AerialNavToggle<CR>", desc = "Navigate blocks" },
        },
        opts = {
            backends = { "treesitter" },
            default_direction = { "prefer_right" },
        },
    },
    {
        "tpope/vim-fugitive",
        keys = {
            { "<leader>g", "<cmd>Git<CR>", desc = "Git status", mode = "n" },
        },
    },
}
