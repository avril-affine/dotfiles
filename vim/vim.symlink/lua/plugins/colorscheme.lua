return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("tokyonight").setup({
        style = "night",
        dim_inactive = true,
        on_highlights = function(hl, c)
          hl.Normal = { fg = c.white, bg = c.bg }
          hl.Comment = { fg = '#ffdfaf' }
          hl.LineNr = { fg = c.white, bg = '#4c4e52' }
          hl.CursorLineNr = { fg = c.cyan }
          hl.SignColumn = { bg = '#4c4e52' }
        end,
        })
        vim.cmd.colorscheme("tokyonight")
    end,
}
