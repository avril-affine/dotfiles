return {
    "dhruvasagar/vim-zoom",
    lazy = false,
    init = function()
        vim.g["zoom#statustext"] = "(zoomed)"
    end,
    keys = {
        { "<leader>z", "<Plug>(zoom-toggle)", desc = "Zoom window." },
    },
}
