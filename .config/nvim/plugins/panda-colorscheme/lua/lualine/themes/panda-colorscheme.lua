local p = require("panda_colorscheme.palette")

local function section(fg, bg, gui)
    return { fg = fg, bg = bg, gui = gui }
end

return {
    normal = {
        a = section(p.bg, p.parameter, "bold"),
        b = section(p.parameter, p.surface),
        c = section(p.fg, p.bg_dark),
    },
    insert = {
        a = section(p.bg, p.string, "bold"),
        b = section(p.string, p.surface),
        c = section(p.fg, p.bg_dark),
    },
    visual = {
        a = section(p.selected_fg, p.attribute, "bold"),
        b = section(p.attribute, p.surface),
        c = section(p.fg, p.bg_dark),
    },
    replace = {
        a = section(p.white, p.error_bg, "bold"),
        b = section(p.local_, p.surface),
        c = section(p.fg, p.bg_dark),
    },
    command = {
        a = section(p.bg, p.global, "bold"),
        b = section(p.global, p.surface),
        c = section(p.fg, p.bg_dark),
    },
    terminal = {
        a = section(p.bg, p.free, "bold"),
        b = section(p.free, p.surface),
        c = section(p.fg, p.bg_dark),
    },
    inactive = {
        a = section(p.self, p.bg_dark, "bold"),
        b = section(p.overlay, p.bg_dark),
        c = section(p.overlay, p.bg_dark),
    },
}
