return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
        opts = function(_, opts)
            local actions = require("telescope.actions")
            return {
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
            }
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
        opts = {
            columns = {
                "icon",
                "permissions",
                "size",
                "mtime",
            },
        },
        keys = {
            { "<leader>k", function() require("oil").open_float() end },
        },
	},
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "nvim-treesitter/nvim-treesitter-context",
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
            -- highlight = {
            --     enable = true,
            -- },
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
                max_lines = 5,
                separator = "-",
            },
        },
        config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end,
	},
	{
		"machakann/vim-swap",
	},
    {
        "echasnovski/mini.surround",
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
                find = "",
                find_left = "",
                highlight = "",
                update_n_lines = "",
                suffix_last = "",
                suffix_next = "",
            },
        },
        config = function(_, opts)
            require("mini.surround").setup(opts)
            for fn_name, mapping in ipairs(opts.mappings) do
                if fn_name == "add" then
                    vim.keymap.set("v", mapping, function() require("mini.surround")[fn_name]("v") end, { silent = true })
                else
                    vim.keymap.set("v", mapping, function() require("mini.surround")[fn_name]() end, { silent = true })
                end
            end
        end,
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
            default_direction = { "prefer_right" },
        },
    },
    {
        "mbbill/undotree",
    },
    {
        "tpope/vim-fugitive",
        lazy = false,
        keys = {
            { "<leader>g", "<cmd>Git<CR>", desc = "Git status", mode = "n" },
        },
    },
}
