return {
    {
        "echasnovski/mini.surround",
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
        keys = {
            { "<leader>sa", desc = "Add surrounding", mode = { "n", "v" } },
            { "<leader>sd", desc = "Delete surrounding", mode = { "n", "v" } },
            { "<leader>ss", desc = "Replace surrounding", mode = { "n", "v" } },
        },
    },
    {
        "echasnovski/mini.indentscope",
        version = false, -- wait till new 0.7.0 release to put it back on semver
        event = { "BufReadPre", "BufNewFile" },
        opts = {
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
}
