return {
    {
        dir = vim.fn.stdpath("config") .. "/plugins/panda-colorscheme",
        name = "panda-colorscheme",
        lazy = false,
        priority = 2000,
        config = function()
            vim.cmd.colorscheme("panda-colorscheme")
        end,
    },
}
