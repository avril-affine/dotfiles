return {
    "stevearc/aerial.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        backends = { "treesitter" },
        default_direction = { "prefer_right" },
    },
    keys = {
        { "<leader>a", "<cmd>AerialToggle!<CR>", desc = "Navigate blocks side pane" },
        { "<leader>A", "<cmd>AerialNavToggle<CR>", desc = "Navigate blocks" },
    },
}
