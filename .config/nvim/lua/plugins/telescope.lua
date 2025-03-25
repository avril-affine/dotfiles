local multi_ripgrep = function(opts)
    local conf = require("telescope.config").values
    local finders = require "telescope.finders"
    local make_entry = require "telescope.make_entry"
    local pickers = require "telescope.pickers"

    local opts = opts or {}
    opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()
    opts.pattern = opts.pattern or "%s"

    local custom_grep = finders.new_async_job {
        command_generator = function(prompt)
            if not prompt or prompt == "" then
                return nil
            end

            local args = { "rg" }

            local prompt_split = vim.split(prompt, "  ")
            if prompt_split[1] then
                table.insert(args, "-e")
                table.insert(args, prompt_split[1])
            end
            if prompt_split[2] then
                table.insert(args, "--glob")
                table.insert(args, string.format(opts.pattern, prompt_split[2]))
            end

            return vim.tbl_flatten({
                args,
                {
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--glob", "!*.json",
                    "--glob", "!*.jsonl",
                    "--glob", "!*.dot",
                    "--glob", "!*log*",
                },
            })
        end,
        entry_maker = make_entry.gen_from_vimgrep(opts),
        cwd = opts.cwd,
    }

    pickers
        .new(opts, {
            debounce = 100,
            prompt_title = "Multi Ripgrep",
            finder = custom_grep,
            previewer = conf.grep_previewer(opts),
            sorter = require("telescope.sorters").empty(),
        })
        :find()
end

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
            { "<leader>f", multi_ripgrep, desc = "Multi ripgrep, fuzzy search." },
            { "<leader>F", function() require("telescope.builtin").live_grep() end, desc = "Live grep." },
            { "<leader>h", function() require("telescope.builtin").help_tags() end, desc = "Help tags." },
        },
	},
}
