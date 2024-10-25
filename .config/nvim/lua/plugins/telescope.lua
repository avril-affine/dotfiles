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
        keys = {
            { "<C-p>", function() require("telescope.builtin").find_files() end, desc = "Open file finder." },
            { ",p", function() require("telescope.builtin").registers() end, desc = "Open registers and paste." },
        },
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		build = "make",
		config = function()
			require("telescope").load_extension("fzf")
		end,
        keys = {
            { "<leader>f", function() require("telescope.builtin").live_grep() end, desc = "Live grep." },
        },
	},
}
