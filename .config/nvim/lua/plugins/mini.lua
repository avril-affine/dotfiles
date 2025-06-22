local curly = { brackets = { '%b{}' } }
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
        "echasnovski/mini.files",
        lazy = false,
        opts = {
            mappings = {
                close       = "<ESC>",
                go_in       = "l",
                go_in_plus  = "<CR>",
                go_out      = "h",
                go_out_plus = "H",
                mark_goto   = "'",
                mark_set    = "m",
                reset       = "<BS>",
                reveal_cwd  = "@",
                show_help   = "g?",
                synchronize = "w",
                trim_left   = "<",
                trim_right  = ">",
            },
        },
        keys = {
            { "<leader>k", function() MiniFiles.open() end, desc = "mini.files" },
        },
    },
    {
        "echasnovski/mini.splitjoin",
        config = function()
            local gen_hook = require("mini.splitjoin").gen_hook
            require("mini.splitjoin").setup({
                mappings = {
                    toggle = "<leader>J",
                    split  = "",
                    join   = "<leader>j",
                },
                split = {
                    hooks_post = {
                        gen_hook.add_trailing_separator(),
                    },
                },
                join = {
                    hooks_post = {
                        gen_hook.del_trailing_separator(),
                    },
                },
            })
        end,
    },
}
