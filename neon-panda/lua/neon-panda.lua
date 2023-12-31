local lush = require("lush")
local hsl = lush.hsl
local hsluv = lush.hsluv

local P = {
    black1 = hsl("#191922"),
    black2 = hsl("#545c7e"),
    black3 = hsl("#737aa2"),
    white = hsl("#c8d3f5"),
    red = hsl("#ff757f"),
    orange = hsl("#ffb347"),
    yellow = hsl("#ffff00"),
    green = hsl("#c3e88d"),
    purple = hsl("#c099ff"),
    cyan = hsl("#86e1fc"),
    teal = hsl("#4fd6be"),
    magenta = hsl("#fca7ea"),
}

local N = {
    black = hsl("#000000"),
    white = hsl("#ffffff"),
    red = hsl("#ff3131"),
    orange = hsl("#ffaf00"),
    green = hsl("#39ff14"),
    lime = hsl("#00ffaf"),
    blue = hsl("#04d9ff"),
    purple = hsl("#4d4dff"),
    pink = hsl("#ff007c"),
}

local theme = lush(function(injected_functions)
    local sym = injected_functions.sym

    return {
        -- Editor ---------------------------------------------------------------------------------------------------------------------------------------

		Normal          { fg = P.white, bg = P.black1 },
		NormalNC        { fg = Normal.fg, bg = Normal.bg.darken(50) },
        NonText         { fg = Normal.bg },
		Delimiter       { fg = P.cyan, bg = "NONE" },
		Visual          { fg = N.black, bg = N.blue, gui = "bold" },
		Substitute      { Visual },
		QuickFixLine    { Visual },
		Search          { Visual },
		IncSearch       { Search },
		CurSearch       { Search },  -- Used for highlighting a search pattern under the cursor
		ColorColumn     { fg = P.black3, bg = "NONE" },
		Conceal         { fg = P.black3 },
		Cursor          { fg = Normal.bg, bg = Normal.fg },
		lCursor         { Cursor },
		CursorIM        { Cursor },
		CursorColumn    { Cursor },
		CursorLine      { bg = P.black2 },
		CursorLineSign  { CursorLine },
        NormalFloat     { fg = "NONE", bg = "NONE" },
        Pmenu           { bg = Normal.bg.lighten(10) },
        PmenuSel        { bg = CursorLine.bg.lighten(15) },
        -- PmenuSbar                                                                         { bg="#45475a", }, -- PmenuSbar      xxx guibg=#45475a
        -- PmenuThumb                                                                        { bg="#6c7086", }, -- PmenuThumb     xxx guibg=#6c7086
		Directory       { fg = P.cyan },
		VertSplit       { fg = N.white },
		Folded          { fg = P.cyan, bg = P.black3 },
		FoldColumn      { fg = P.black3 },
        SignColumn      { fg = P.black3 },
        SignColumnSB    { SignColumn },
		LineNr          { fg = Normal.fg },
		CursorLineNr    { fg = P.teal, bg = CursorLine.bg, gui = "bold" },
		MatchParen      { fg = N.pink, gui = "bold" },
		FloatBorder     { fg = N.blue },
		WinSeparator    { fg = N.white },
        StatusLine      { fg = Normal.fg, bg = N.black },
        Title           { fg = N.orange, gui = "bold" },
        Todo            { fg = N.black, bg = P.magenta, gui = "bold" },
		WarningMsg      { fg = N.black, bg = P.orange, gui = "bold" },
		Error           { fg = N.black, bg = P.red, gui = "bold" },
		ErrorMsg        { Error },

        -- indent blankline
        IndentBlanklineChar         { fg = Normal.bg.lighten(20) },
        IndentBlanklineContextChar  { fg = P.cyan, bg = "NONE" },

        -- qfFileName                                                                        { fg="#89b4fa", }, -- qfFileName     xxx guifg=#89b4fa
        -- qfLineNr                                                                          { fg="#f9e2af", }, -- qfLineNr       xxx guifg=#f9e2af

        -- TreesitterContext                                                                 { bg="#585b70", }, -- TreesitterContext xxx guibg=#585b70

        -- Text ---------------------------------------------------------------------------------------------------------------------------------------

        Statement                   { fg = Normal.fg },
        String                      { fg = P.green },
        Character                   { String },
        Constant                    { fg = P.orange },
        Number                      { Constant },
        Float                       { Constant },
        Boolean                     { Constant },
        Function                    { fg = P.teal },
        sym"@function"              { Function },
        sym"@method"                { Function },
        sym"@attribute"             { fg = N.lime },
        -- sym"@field"                                                                       { fg="#94e2d5", }, -- @field         xxx guifg=#94e2d5
        -- sym"@property"                                                                    { fg="#b4befe", }, -- @property      xxx guifg=#b4befe
        Identifier                  { fg = Normal.fg },
        sym"@operator"              { Identifier },
        -- sym"@variable"              { fg = P.cyan },
        sym"@parameter"             { fg = P.cyan },
        Type                        { fg = N.orange, gui = "bold" },
        Struct                      { Type },
        Keyword                     { fg = P.purple, gui = "bold" },
        Conditional                 { Keyword },
        Repeat                      { Keyword },
        Include                     { Keyword },
        sym"@variable.builtin"      { Keyword },
        sym"@function.builtin"      { Keyword },
        sym"@type.builtin"          { fg = N.pink },
        Exception                   { sym"@type.builtin" },
        Comment                     { fg = P.white.darken(20) },
        sym"@punctuation"           { fg = Normal.fg, bg = "NONE" },
        sym"@punctuation.bracket"   { fg = N.white },
        sym"@constructor"           { sym"@punctuation.bracket" },
        
        -- nvim-cmp
        CmpItemKindText             { fg = Normal.fg, bg = "NONE" },
        CmpItemKindSnippet          { CmpItemKindText },
        CmpItemAbbrMatch            { Visual },
        CmpItemAbbrMatchFuzzy       { CmpItemAbbrMatch },
        CmpItemKindVariable         { fg = P.cyan, bg = "NONE" },
        CmpItemKindTypeParameter    { CmpItemKindVariable },
        CmpItemKindFunction         { fg = Function.fg, bg = "NONE" },
        CmpItemKindMethod           { CmpItemKindFunction },
        CmpItemKindKeyword          { fg = Keyword.fg, bg = "NONE" },
        CmpItemKindUnit             { CmpItemKindKeyword },
        CmpItemKindField            { fg = sym"@attribute".fg, bg = "NONE" },
        CmpItemKindProperty         { CmpItemKindField },
        CmpItemKindClass            { fg = Type.fg, bg = "NONE", gui = Type.gui },
        CmpItemKindStruct           { CmpItemKindClass },
        CmpItemKindModule           { CmpItemKindClass },
        CmpItemKindEnum             { CmpItemKindClass },
        CmpItemKindInterface        { CmpItemKindClass },
        CmpItemKindConstant         { fg = Constant.fg, bg = "NONE" },
        CmpItemKindFile             { fg = Normal.fg, bg = "NONE", gui = "italic" },
        CmpItemKindFolder           { fg = Directory.fg, bg = "NONE", gui = "italic" },


        -- Diagnostics ------------------------------------------------------------------------------------------------------------------------------

        DiagnosticUnnecessary               { fg = P.yellow },
    }
end)
return theme
