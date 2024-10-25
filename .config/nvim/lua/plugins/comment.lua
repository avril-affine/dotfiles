return {
    "numToStr/Comment.nvim",
    opts = {
        mappings = { basic = false, extra = false },
    },
    config = function(_, opts)
        require("Comment").setup(opts)
        local ft = require("Comment.ft")
        ft.set("python", { "#%s", '"""\n%s\n"""' })
    end,
    keys = {
        {
            "/",
            function()
                local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
                vim.api.nvim_feedkeys(esc, "nx", false)
                require("Comment.api").toggle.linewise(vim.fn.visualmode())
            end,
            mode = "v",
            { desc = "Comment toggle linewise (visual)" },
        },
        {
            "\\",
            function()
                local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
                vim.api.nvim_feedkeys(esc, "nx", false)
                require("Comment.api").toggle.blockwise(vim.fn.visualmode())
            end,
            mode = "v",
            { desc = "Comment toggle blockwise (visual)" },
        },
    },
}
