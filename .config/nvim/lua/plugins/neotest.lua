return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
        },
        config = function(_, opts)
            require("neotest").setup({
                adapters = {
                    require("neotest-python")({
                        -- neotest-python config
                    }),
                },
            })
        end,
        keys = {
            { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "[Neotest] Toggle summary" },
            { "<leader>to", function() require("neotest").output_panel.open() end, desc = "[Neotest] Open output panel" },
            {
                "<leader>tr",
                function()
                    require("neotest").output_panel.clear()
                    require("neotest").summary.run_marked()
                end,
                desc = "[Neotest] Run marked tests",
            },
            {
                "<leader>tR",
                function()
                    require("neotest").output_panel.clear()
                    require("neotest").run.run()
                end,
                desc = "[Neotest] Run closest test",
            },
        },
    },
}
