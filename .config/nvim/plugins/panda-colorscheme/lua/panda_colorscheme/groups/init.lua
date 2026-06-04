local modules = {
    "editor",
    "syntax",
    "treesitter",
    "lsp",
    "plugins",
}

local M = {}

function M.get()
    local ret = {}

    for _, name in ipairs(modules) do
        local groups = require("panda_colorscheme.groups." .. name)

        for group, spec in pairs(groups) do
            ret[group] = spec
        end
    end

    return ret
end

return M
