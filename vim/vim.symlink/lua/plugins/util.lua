return {
    -- measure startuptime
    {
        "dstein64/vim-startuptime",
        cmd = "StartupTime",
        config = function()
            vim.g.startuptime_tries = 10
        end,
    },

    -- session management
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" } },
        -- stylua: ignore
        keys = {
            { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
            { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
            { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
        },
    },

    -- library used by other plugins
    { "nvim-lua/plenary.nvim", lazy = true },

    -- note taking
    {
        "renerocksai/telekasten.nvim",
        lazy = false,
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        keys = {
            -- Launch panel if nothing is typed after <leader>z
            { "<leader>z", function() require("telekasten").panel() end, desc = "" },

            -- Most used functions
            { "<leader>zf", function() require("telekasten").find_notes() end, desc = "" },
            { "<leader>zs", function() require("telekasten").search_notes() end, desc = "" },
            { "<leader>zt", function() require("telekasten").goto_today() end, desc = "" },
            { "<leader>zd", function() require("telekasten").follow_link() end, desc = "" },
            { "<leader>zN", function() require("telekasten").new_note() end, desc = "" },
            { "<leader>zn", function() require("telekasten").template_note() end, desc = "" },
            { "<leader>zc", function() require("telekasten").show_calendar() end, desc = "" },
            { "<leader>zb", function() require("telekasten").show_backlinks() end, desc = "" },
        },
        opts = function(_, opts)
            -- mkdir if not exists
            local home = vim.fn.expand("~/zettelkasten")
            if os.execute("ls " .. home) ~= 0 then
                os.execute("mkdir " .. home)
            end

            -- templates
            local lua_dir = debug.getinfo(1).source:match("@?(.*/).*/")
            local template_dir = lua_dir .. "/tk_templates"

            opts.home = home
            opts.dailies = home .. "/daily"
            opts.weeklies = home .. "/weekly"
            opts.templates = home .. "/templates"

            opts.template_new_note = template_dir .. "/note.md"
            opts.template_new_daily = template_dir .. "/daily.md"
            opts.template_new_weekly = template_dir .. "/weekly.md"

            opts.extension = ".md"

            opts.follow_creates_nonexisting = true
            opts.dailies_create_nonexisting = true
            opts.weeklies_create_nonexisting = true
        end,
    },
}
