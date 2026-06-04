local M = {}

function M.load()
    vim.cmd.highlight("clear")

    if vim.fn.exists("syntax_on") == 1 then
        vim.cmd.syntax("reset")
    end

    vim.o.background = "dark"
    vim.o.termguicolors = true
    vim.g.colors_name = "panda-colorscheme"

    local groups = require("panda_colorscheme.groups").get()
    for name, spec in pairs(groups) do
        vim.api.nvim_set_hl(0, name, spec)
    end
end

return M
