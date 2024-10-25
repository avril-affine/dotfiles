return {
    "stevearc/oil.nvim",
    opts = {
        columns = {
            "icon",
            "permissions",
            "size",
            "mtime",
        },
    },
    keys = {
        { "<leader>k", function() require("oil").open_float() end },
    },
}
