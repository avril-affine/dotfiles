return {
    {
        "nvim-telescope/telescope.nvim",
        requires = { "nvim-lua/plenary.nvim" },
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
        keys = {
            vim.keymap.set("n", "<leader>f", "<cmd>lua require('telescope.builtin').live_grep()<CR>", { nowait = true, silent = true }),
            vim.keymap.set("n", "<C-P>", "<cmd>lua require('telescope.builtin').find_files()<CR>", { nowait = true, silent = true }),
        },
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
        init = function ()
            require("oil").setup({
                columns = {
                    "icon",
                    "permissions",
                    "size",
                    "mtime",
                },
            })
        end,
        keys = {
            vim.keymap.set("n", "<leader>k", require("oil").open_float, { desc = "Open parent directory" }),
        },
    },
}
