return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		init = function()
			require("telescope").setup({
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "respect_case",
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
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects", "nvim-treesitter/playground" },
		build = ":TSUpdate",
		init = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "lua", "javascript", "typescript", "python", "rust" }, -- can specify "all"
				-- highlights
				highlight = {
					enable = true,
					disable = { "python" },
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
				query_linter = {
					enable = true,
					use_virtual_text = true,
					lint_events = { "BufWrite", "CursorHold" },
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
			})
		end,
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
        -- stylua: ignore
        keys = {
            { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "Delete Buffer" },
            { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
        },
    },
}
