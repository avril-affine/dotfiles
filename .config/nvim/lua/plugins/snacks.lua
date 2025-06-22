return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        picker = {
            enabled = true,
            -- debug = {
            --     scores = true,
            -- },
            layout = {
                preset = "ivy",
                cycle = false,
            },
            matcher = {
                frecency = true,
            },
        },
        scroll = {
            enabled = true,
        },
        indent = {
            enabled = true,
            priority = 1,
            only_scope = true,
            only_current = true,
            animate = {
                duration = {
                    step = 40,
                    duration = 500,
                },
            },
            scope = {
                enabled = true,
                priority = 200,
                underline = true,
                only_current = true,
            },
        },
    },
    keys = {
        -- <C-a> select all
        -- <C-q> send to quickfix list
        -- <C-b> preview scroll up
        -- <C-f> preview scroll down
        {
            "<C-p>",
            function()
                -- Snacks.picker.explorer()
                Snacks.picker.files({
                    finder = "files",
                    format = "file",
                    show_empty = true,
                    supports_live = true,
                })
            end,
            desc = "Find files",
        },
        {
            "<leader>f",
            function()
                Snacks.picker.grep({
                    exclude = {
                        "*.json",
                        "*.jsonl",
                        "*.dot",
                        "*.log",
                    },
                })
            end,
            desc = "Live grep",
        },
        { "<leader>F", function() Snacks.picker.grep() end, desc = "Live grep, exclude data files" },
        { "<leader>F", function() Snacks.picker.grep() end, desc = "Live grep" },
        { "<leader>p", function() Snacks.picker.registers() end, desc = "Search registers" },
        { "<leader>q", function() Snacks.picker.qflist() end, desc = "Search quickfix list" },
        { "<leader>h", function() Snacks.picker.help() end, desc = "Help tags" },
        { "<leader>gb", function() Snacks.gitbrowse() end, desc = "Git browse" },
        { "<leader>gB", function() Snacks.gitbrowse({ branch = "master" }) end, desc = "Git browse master" },
    },
}
