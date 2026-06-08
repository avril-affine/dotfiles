local p = require("panda_colorscheme.palette")

return {
    Comment = { fg = p.comment },
    String = { fg = p.string },
    Character = { fg = p.string },
    Constant = { fg = p.free },
    Number = { fg = p.literal },
    Boolean = { fg = p.literal },
    Float = { link = "Number" },

    Identifier = { fg = p.fg },
    Function = { fg = p.attribute },

    Statement = { fg = p.keyword },
    Conditional = { fg = p.keyword },
    Repeat = { fg = p.keyword },
    Label = { fg = p.parameter },
    Operator = { fg = p.fg },
    Keyword = { fg = p.keyword },
    Exception = { fg = p.keyword },

    PreProc = { fg = p.none },
    Include = { fg = p.keyword, bold = true },
    Define = { link = "PreProc" },
    Macro = { fg = p.keyword },
    PreCondit = { link = "PreProc" },

    Type = { fg = p.imported, bold = true },
    StorageClass = { fg = p.imported },
    Structure = { fg = p.imported, bold = true },
    Typedef = { link = "Type" },

    Special = { fg = p.builtin },
    SpecialChar = { link = "Special" },
    Tag = { fg = p.parameter_unused, bold = true },
    Delimiter = { fg = p.self },
    SpecialComment = { link = "Special" },
    Debug = { link = "Special" },

    gitHead = { link = "String" },
    qfFileName = { fg = p.parameter },
    qfLineNr = { fg = p.global },
}
