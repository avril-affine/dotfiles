return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                dependencies = { "nvim-telescope/telescope.nvim" },
                build = "make",
                config = function()
                    require("telescope").load_extension("fzf")
                end,
            },
        },
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
                pickers = {
                    find_files = {
                        theme = "ivy",
                    },
                    help_tags = {
                        theme = "ivy",
                    },
                    registers = {
                        theme = "ivy",
                    },
                    live_grep = {
                        theme = "ivy",
                    },
                },
                defaults = {
                    mappings = {
                        n  = {
                            ["<leader>qf"] = actions.send_selected_to_qflist + actions.open_qflist,
                            ["<leader>qF"] = actions.smart_send_to_qflist + actions.open_qflist,
                        },
                    },
                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                    },
                },
            }
        end,
        keys = {
            { "<C-p>", function() require("telescope.builtin").find_files() end, desc = "Open file finder." },
            { "<leader>p", function() require("telescope.builtin").registers() end, desc = "Open registers and paste." },
            {
                "<leader>f",
                function()
                    require("telescope.builtin").live_grep({glob_pattern = {"!*.json", "!*.jsonl", "!*.dot", "!*log*"}})
                end,
                desc = "Live grep, ignore log files."
            },
            { "<leader>h", function() require("telescope.builtin").help_tags() end, desc = "Help tags." },
        },
	},
}
