return {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
    lazy = false,
    keys = {
        { "<leader>g", "<cmd>Git<CR>", desc = "Git status", mode = "n" },
    },
}
