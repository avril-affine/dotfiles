return {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
    lazy = false,
    keys = {
        { "<leader>g", "<cmd>Git<CR>", desc = "Git", mode = "n" },
        { "<leader>gl", "<cmd>G log --decorate<CR>", desc = "Git status", mode = "n" },
        { "<leader>gd", "<cmd>Gvdiffsplit<CR>", desc = "Git diff", mode = "n" },
    },
}
