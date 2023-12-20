local lush = require("lush")
local hsl = lush.hsl
local hsluv = lush.hsluv

local P = {
    -- black1 = hsl("#2f334d"),
    black1 = hsl("#1e1e2e"),
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
		Visual          { fg = N.black, bg = N.blue, style = "bold" },
		Substitute      { Visual },
		QuickFixLine    { Visual },
		Search          { Visual },
		IncSearch       { Search },
		CurSearch       { Search },  -- Used for highlighting a search pattern under the cursor
		ColorColumn     { bg = P.black3, bg = "NONE" },
		Conceal         { fg = P.black3 },
		Cursor          { fg = Normal.bg, bg = Normal.fg },
		lCursor         { Cursor },
		CursorIM        { Cursor },
		CursorColumn    { Cursor },
		CursorLine      { bg = P.black2 },
		CursorLineSign  { CursorLine },
        NormalFloat     { fg = "NONE", bg = "NONE" },
		Directory       { fg = P.cyan },
		VertSplit       { fg = N.white },
		Folded          { fg = P.cyan, bg = P.black3 },
		FoldColumn      { fg = P.black3 },
        SignColumn      { fg = P.black3 },
        SignColumnSB    { SignColumn },
		LineNr          { fg = Normal.fg },
		CursorLineNr    { fg = P.teal, bg = CursorLine.bg, gui = "bold" },
		MatchParen      { fg = N.pink, style = "bold" },
		FloatBorder     { fg = N.blue },
		WinSeparator    { fg = N.white },
        StatusLine      { fg = Normal.fg, bg = N.black },
        Todo            { fg = N.black, bg = P.magenta, style = "bold" },
		WarningMsg      { fg = N.black, bg = P.orange, style = "bold" },
		Error           { fg = N.black, bg = P.red, style = "bold" },
		ErrorMsg        { Error },

        -- noice

        -- indent blankline
        IndentBlanklineChar         { fg = Normal.bg.lighten(20) },
        IndentBlanklineContextChar  { fg = P.cyan, bg = "NONE" },

        -- qfFileName                                                                        { fg="#89b4fa", }, -- qfFileName     xxx guifg=#89b4fa
        -- qfLineNr                                                                          { fg="#f9e2af", }, -- qfLineNr       xxx guifg=#f9e2af


        -- TreesitterContext                                                                 { bg="#585b70", }, -- TreesitterContext xxx guibg=#585b70


        -- Text ---------------------------------------------------------------------------------------------------------------------------------------

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
        Identifier                  { fg = Normal.fg },
        sym"@variable"              { Identifier },
        sym"@operator"              { Identifier },
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
        -- sym"@parameter"                                                                   { fg="#89b4fa", }, -- @parameter     xxx guifg=#89b4fa
        -- sym"@field"                                                                       { fg="#94e2d5", }, -- @field         xxx guifg=#94e2d5
        -- sym"@property"                                                                    { fg="#b4befe", }, -- @property      xxx guifg=#b4befe



        -- Statement                                                                         { fg="#cba6f7", }, -- Statement      xxx guifg=#cba6f7
        -- sym"@include"                                                                     { Include }, -- @include       xxx links to Include
        -- PreProc                                                                           { fg="#f5c2e7", }, -- PreProc        xxx guifg=#f5c2e7
        -- Define                                                                            { PreProc }, -- Define         xxx links to PreProc
        -- PreCondit                                                                         { PreProc }, -- PreCondit      xxx links to PreProc
        -- sym"@preproc"                                                                     { PreProc }, -- @preproc       xxx links to PreProc
        -- Macro                                                                             { fg="#cba6f7", }, -- Macro          xxx guifg=#cba6f7
        -- sym"@constant.macro"                                                              { Macro }, -- @constant.macro xxx links to Macro
        -- sym"@macro"                                                                       { Macro }, -- @macro         xxx links to Macro
        -- sym"@lsp.type.macro"                                                              { Macro }, -- @lsp.type.macro xxx links to Macro
        -- Typedef                                                                           { Type }, -- Typedef        xxx links to Type
        -- sym"@type.definition"                                                             { Type }, -- @type.definition xxx links to Type
        -- sym"@lsp.type.type"                                                               { Type }, -- @lsp.type.type xxx links to Type
        -- Structure                                                                         { fg="#f9e2af", }, -- Structure      xxx guifg=#f9e2af
        -- sym"@lsp.type.class"                                                              { Structure }, -- @lsp.type.class xxx links to Structure
        -- sym"@lsp.type.struct"                                                             { Structure }, -- @lsp.type.struct xxx links to Structure
        -- sym"@function.macro"                                                              { fg="#94e2d5", }, -- @function.macro xxx guifg=#94e2d5
        -- sym"@lsp.type.parameter"                                                          { sym"@parameter" }, -- @lsp.type.parameter xxx links to @parameter
        -- sym"@lsp.type.property"                                                           { sym"@property" }, -- @lsp.type.property xxx links to @property
        -- sym"@constructor"                                                                 { gui="bold", fg="#fab387", }, -- @constructor   xxx cterm=bold gui=bold guifg=#fab387
        -- sym"@type"                                                                        { sym"@constructor" }, -- @type          xxx links to @constructor
        -- sym"@variable"                                                                    { fg="#cdd6f4", }, -- @variable      xxx guifg=#cdd6f4
        -- sym"@lsp.typemod.variable.injected"                                               { sym"@variable" }, -- @lsp.typemod.variable.injected xxx links to @variable
        -- sym"@namespace"                                                                   { fg="#b4befe", }, -- @namespace     xxx guifg=#b4befe
        -- sym"@lsp.type.namespace"                                                          { sym"@namespace" }, -- @lsp.type.namespace xxx links to @namespace
        -- sym"@tag"                                                                         { fg="#cba6f7", }, -- @tag           xxx guifg=#cba6f7
        -- sym"@lsp.type.interface"                                                          { fg="#f2cdcd", }, -- @lsp.type.interface xxx guifg=#f2cdcd
        -- sym"@keyword.return"                                                              { fg="#cba6f7", }, -- @keyword.return xxx guifg=#cba6f7

        -- Diagnostics ------------------------------------------------------------------------------------------------------------------------------

        -- LspDiagnosticsDefaultError                                                        { fg="#f38ba8", }, -- LspDiagnosticsDefaultError xxx guifg=#f38ba8
        -- LspDiagnosticsDefaultHint                                                         { fg="#94e2d5", }, -- LspDiagnosticsDefaultHint xxx guifg=#94e2d5
        -- LspDiagnosticsVirtualTextWarning                                                  { fg="#f9e2af", }, -- LspDiagnosticsVirtualTextWarning xxx guifg=#f9e2af
        -- LspDiagnosticsUnderlineWarning                                                    { sp="#f9e2af", gui="underline", }, -- LspDiagnosticsUnderlineWarning xxx cterm=underline gui=underline guisp=#f9e2af
        -- LspDiagnosticsUnderlineInformation                                                { sp="#89dceb", gui="underline", }, -- LspDiagnosticsUnderlineInformation xxx cterm=underline gui=underline guisp=#89dceb
        -- LspDiagnosticsUnderlineError                                                      { sp="#f38ba8", gui="underline", }, -- LspDiagnosticsUnderlineError xxx cterm=underline gui=underline guisp=#f38ba8
        -- LspDiagnosticsVirtualTextHint                                                     { fg="#94e2d5", }, -- LspDiagnosticsVirtualTextHint xxx guifg=#94e2d5
        -- LspDiagnosticsVirtualTextInformation                                              { fg="#89dceb", }, -- LspDiagnosticsVirtualTextInformation xxx guifg=#89dceb
        -- LspDiagnosticsVirtualTextError                                                    { fg="#f38ba8", }, -- LspDiagnosticsVirtualTextError xxx guifg=#f38ba8
        -- LspDiagnosticsDefaultInformation                                                  { fg="#89dceb", }, -- LspDiagnosticsDefaultInformation xxx guifg=#89dceb
        -- LspDiagnosticsWarning                                                             { fg="#f9e2af", }, -- LspDiagnosticsWarning xxx guifg=#f9e2af
        -- LspDiagnosticsHint                                                                { fg="#94e2d5", }, -- LspDiagnosticsHint xxx guifg=#94e2d5
        -- LspDiagnosticsUnderlineHint                                                       { sp="#94e2d5", gui="underline", }, -- LspDiagnosticsUnderlineHint xxx cterm=underline gui=underline guisp=#94e2d5
        -- LspDiagnosticsInformation                                                         { fg="#89dceb", }, -- LspDiagnosticsInformation xxx guifg=#89dceb
        -- LspDiagnosticsError                                                               { fg="#f38ba8", }, -- LspDiagnosticsError xxx guifg=#f38ba8
        -- LspDiagnosticsDefaultWarning                                                      { fg="#f9e2af", }, -- LspDiagnosticsDefaultWarning xxx guifg=#f9e2af
        -- LspCodeLens                                                                       { fg="#6c7086", }, -- LspCodeLens    xxx guifg=#6c7086
        -- LspInlayHint                                                                      { bg="#2a2b3c", fg="#6c7086", }, -- LspInlayHint   xxx guifg=#6c7086 guibg=#2a2b3c
        -- LspReferenceWrite                                                                 { bg="#45475a", }, -- LspReferenceWrite xxx guibg=#45475a
        -- LspReferenceRead                                                                  { bg="#45475a", }, -- LspReferenceRead xxx guibg=#45475a
        -- LspReferenceText                                                                  { bg="#45475a", }, -- LspReferenceText xxx guibg=#45475a

        -- DiagnosticError                                                                   { fg="#f38ba8", }, -- DiagnosticError xxx guifg=#f38ba8
        -- DiagnosticWarn                                                                    { fg="#f9e2af", }, -- DiagnosticWarn xxx guifg=#f9e2af
        -- DiagnosticInfo                                                                    { fg="#89dceb", }, -- DiagnosticInfo xxx guifg=#89dceb
        -- DiagnosticHint                                                                    { fg="#94e2d5", }, -- DiagnosticHint xxx guifg=#94e2d5
        -- DiagnosticOk                                                                      { fg="lightgreen", }, -- DiagnosticOk   xxx ctermfg=10 guifg=LightGreen
        -- DiagnosticVirtualTextOk                                                           { DiagnosticOk }, -- DiagnosticVirtualTextOk xxx links to DiagnosticOk
        -- DiagnosticFloatingOk                                                              { DiagnosticOk }, -- DiagnosticFloatingOk xxx links to DiagnosticOk
        -- DiagnosticUnderlineError                                                          { sp="#f38ba8", gui="underline", }, -- DiagnosticUnderlineError xxx cterm=underline gui=underline guisp=#f38ba8
        -- DiagnosticUnderlineWarn                                                           { sp="#f9e2af", gui="underline", }, -- DiagnosticUnderlineWarn xxx cterm=underline gui=underline guisp=#f9e2af
        -- DiagnosticUnderlineInfo                                                           { sp="#89dceb", gui="underline", }, -- DiagnosticUnderlineInfo xxx cterm=underline gui=underline guisp=#89dceb
        -- DiagnosticUnderlineHint                                                           { sp="#94e2d5", gui="underline", }, -- DiagnosticUnderlineHint xxx cterm=underline gui=underline guisp=#94e2d5
        -- DiagnosticUnderlineOk                                                             { sp="lightgreen", gui="underline", }, -- DiagnosticUnderlineOk xxx cterm=underline gui=underline guisp=LightGreen
        -- DiagnosticVirtualTextError                                                        { bg="#32283a", fg="#f38ba8", }, -- DiagnosticVirtualTextError xxx guifg=#f38ba8 guibg=#32283a
        -- DiagnosticVirtualTextWarn                                                         { bg="#33313a", fg="#f9e2af", }, -- DiagnosticVirtualTextWarn xxx guifg=#f9e2af guibg=#33313a
        -- DiagnosticVirtualTextInfo                                                         { bg="#283040", fg="#89dceb", }, -- DiagnosticVirtualTextInfo xxx guifg=#89dceb guibg=#283040
        -- DiagnosticVirtualTextHint                                                         { bg="#29313e", fg="#94e2d5", }, -- DiagnosticVirtualTextHint xxx guifg=#94e2d5 guibg=#29313e
        -- DiagnosticFloatingError                                                           { fg="#f38ba8", }, -- DiagnosticFloatingError xxx guifg=#f38ba8
        -- DiagnosticFloatingWarn                                                            { fg="#f9e2af", }, -- DiagnosticFloatingWarn xxx guifg=#f9e2af
        -- DiagnosticFloatingInfo                                                            { fg="#89dceb", }, -- DiagnosticFloatingInfo xxx guifg=#89dceb
        -- DiagnosticFloatingHint                                                            { fg="#94e2d5", }, -- DiagnosticFloatingHint xxx guifg=#94e2d5
        -- DiagnosticSignError                                                               { bg="#313244", fg="#f38ba8", }, -- DiagnosticSignError xxx guifg=#f38ba8 guibg=#313244
        -- DiagnosticSignWarn                                                                { bg="#313244", fg="#f9e2af", }, -- DiagnosticSignWarn xxx guifg=#f9e2af guibg=#313244
        -- DiagnosticSignInfo                                                                { bg="#313244", fg="#89dceb", }, -- DiagnosticSignInfo xxx guifg=#89dceb guibg=#313244
        -- DiagnosticSignHint                                                                { bg="#313244", fg="#94e2d5", }, -- DiagnosticSignHint xxx guifg=#94e2d5 guibg=#313244
        -- DiagnosticSignOk                                                                  { bg="#313244", }, -- DiagnosticSignOk xxx guibg=#313244
        -- DiagnosticDeprecated                                                              { sp="red", gui="strikethrough", }, -- DiagnosticDeprecated xxx cterm=strikethrough gui=strikethrough guisp=Red
        -- DiagnosticUnnecessary                                                             { Comment }, -- DiagnosticUnnecessary xxx links to Comment


        -- probably need?

		-- ModeMsg         { fg = C.fg, style = { "bold" } },   -- 'showmode'
		-- MoreMsg         { fg = C.blue },                     -- more prompt
		-- WildMenu = { bg = C.overlay0 },                      -- current match in 'wildmenu' completion
		-- WinBar = { fg = C.rosewater },                       -- Window bar of current window.
        -- Title { gui="bold", fg="#89b4fa", }, -- Title        -- Titles for output from ":set all", ":autocmd" etc.
        -- DiffAdd { bg="#364143", },                           -- Diff mode: Added line. |diff.txt|
        -- DiffChange { bg="#25293c", },                        -- Diff mode: Changed line. |diff.txt|
        -- DiffDelete { bg="#443244", },                        -- Diff mode: Deleted line. |diff.txt|
        -- DiffText                                             -- Diff mode: Changed text within a changed line. |diff.txt|
        -- SignColumn { bg="#313244", fg="#45475a", }           -- Column where |signs| are displayed.
        -- Conceal { fg="#7f849c", }                            -- Placeholder characters substituted for concealed text (see 'conceallevel').
        -- Pmenu                                                                             { bg="#2b2b3c", fg="#9399b2", }, -- Pmenu          xxx guifg=#9399b2 guibg=#2b2b3c
        -- PmenuSel                                                                          { bg="#45475a", gui="bold", }, -- PmenuSel       xxx cterm=bold gui=bold guibg=#45475a
        -- PmenuSbar                                                                         { bg="#45475a", }, -- PmenuSbar      xxx guibg=#45475a
        -- PmenuThumb                                                                        { bg="#6c7086", }, -- PmenuThumb     xxx guibg=#6c7086
        -- TabLine                                                                           { bg="#181825", fg="#45475a", }, -- TabLine        xxx guifg=#45475a guibg=#181825
        -- TabLineSel                                                                        { bg="#45475a", fg="#a6e3a1", }, -- TabLineSel     xxx guifg=#a6e3a1 guibg=#45475a
        -- QuickFixLine                                                                      { bg="#45475a", gui="bold", }, -- QuickFixLine   xxx cterm=bold gui=bold guibg=#45475a
        -- FloatTitle                                                                        { fg="#a6adc8", }, -- FloatTitle     xxx guifg=#a6adc8
        -- FloatShadow                                                                       { bg="black", blend=80, }, -- FloatShadow    xxx guibg=Black blend=80
        -- FloatShadowThrough                                                                { bg="black", blend=100, }, -- FloatShadowThrough xxx guibg=Black blend=100
        -- RedrawDebugNormal                                                                 { gui="reverse", }, -- RedrawDebugNormal xxx cterm=reverse gui=reverse
        -- RedrawDebugClear                                                                  { bg="yellow", }, -- RedrawDebugClear xxx ctermbg=11 guibg=Yellow
        -- RedrawDebugComposed                                                               { bg="green", }, -- RedrawDebugComposed xxx ctermbg=10 guibg=Green
        -- RedrawDebugRecompose                                                              { bg="red", }, -- RedrawDebugRecompose xxx ctermbg=9 guibg=Red
        -- Error                                                                             { fg="#f38ba8", }, -- Error          xxx guifg=#f38ba8
        -- Character                                                                         { fg="#94e2d5", }, -- Character      xxx guifg=#94e2d5
        -- Repeat                                                                            { fg="#cba6f7", }, -- Repeat         xxx guifg=#cba6f7
        -- sym"@repeat"                                                                      { Repeat }, -- @repeat        xxx links to Repeat
        -- Label                                                                             { fg="#74c7ec", }, -- Label          xxx guifg=#74c7ec
        -- sym"@label"                                                                       { Label }, -- @label         xxx links to Label
        -- Operator                                                                          { fg="#cdd6f4", }, -- Operator       xxx guifg=#cdd6f4
        -- Tag                                                                               { gui="bold", fg="#b4befe", }, -- Tag            xxx cterm=bold gui=bold guifg=#b4befe
        -- sym"@text.reference"                                                              { Tag }, -- @text.reference xxx links to Tag
        -- TelescopeMatching                                                                 { fg="#89b4fa", }, -- TelescopeMatching xxx guifg=#89b4fa
        -- TelescopeSelectionCaret                                                           { fg="#f2cdcd", }, -- TelescopeSelectionCaret xxx guifg=#f2cdcd
        -- TelescopeSelection                                                                { bg="#313244", gui="bold", fg="#cdd6f4", }, -- TelescopeSelection xxx cterm=bold gui=bold guifg=#cdd6f4 guibg=#313244
        -- sym"@tag.delimiter"                                                               { fg="#89dceb", }, -- @tag.delimiter xxx guifg=#89dceb
        -- sym"@tag.attribute"                                                               { fg="#94e2d5", }, -- @tag.attribute xxx guifg=#94e2d5
        -- GlyphPalette9                                                                     { fg="#f38ba8", }, -- GlyphPalette9  xxx guifg=#f38ba8
        -- GlyphPalette7                                                                     { fg="#cdd6f4", }, -- GlyphPalette7  xxx guifg=#cdd6f4
        -- GlyphPalette6                                                                     { fg="#94e2d5", }, -- GlyphPalette6  xxx guifg=#94e2d5
        -- GlyphPalette4                                                                     { fg="#89b4fa", }, -- GlyphPalette4  xxx guifg=#89b4fa
        -- GlyphPalette2                                                                     { fg="#94e2d5", }, -- GlyphPalette2  xxx guifg=#94e2d5
        -- GlyphPalette3                                                                     { fg="#f9e2af", }, -- GlyphPalette3  xxx guifg=#f9e2af
        -- GlyphPalette1                                                                     { fg="#f38ba8", }, -- GlyphPalette1  xxx guifg=#f38ba8
        -- AlphaFooter                                                                       { fg="#f9e2af", }, -- AlphaFooter    xxx guifg=#f9e2af
        -- NormalSB                                                                          { bg="#11111b", fg="#cdd6f4", }, -- NormalSB       xxx guifg=#cdd6f4 guibg=#11111b
        -- AlphaHeader                                                                       { fg="#89b4fa", }, -- AlphaHeader    xxx guifg=#89b4fa
        -- AlphaShortcut                                                                     { fg="#a6e3a1", }, -- AlphaShortcut  xxx guifg=#a6e3a1
        -- AlphaButtons                                                                      { fg="#b4befe", }, -- AlphaButtons   xxx guifg=#b4befe
        -- SignColumnSB                                                                      { bg="#11111b", fg="#45475a", }, -- SignColumnSB   xxx guifg=#45475a guibg=#11111b










        -- lualine_a_command                                                                 { bg="#fab387", gui="bold", fg="#1e1e2e", }, -- lualine_a_command xxx gui=bold guifg=#1e1e2e guibg=#fab387
        -- lualine_b_command                                                                 { bg="#45475a", fg="#fab387", }, -- lualine_b_command xxx guifg=#fab387 guibg=#45475a
        -- lualine_c_inactive                                                                { bg="#181825", fg="#6c7086", }, -- lualine_c_inactive xxx guifg=#6c7086 guibg=#181825
        -- lualine_a_inactive                                                                { bg="#181825", fg="#89b4fa", }, -- lualine_a_inactive xxx guifg=#89b4fa guibg=#181825
        -- lualine_b_inactive                                                                { bg="#181825", gui="bold", fg="#45475a", }, -- lualine_b_inactive xxx gui=bold guifg=#45475a guibg=#181825
        -- lualine_a_visual                                                                  { bg="#cba6f7", gui="bold", fg="#1e1e2e", }, -- lualine_a_visual xxx gui=bold guifg=#1e1e2e guibg=#cba6f7
        -- lualine_b_visual                                                                  { bg="#45475a", fg="#cba6f7", }, -- lualine_b_visual xxx guifg=#cba6f7 guibg=#45475a
        -- lualine_a_terminal                                                                { bg="#a6e3a1", gui="bold", fg="#1e1e2e", }, -- lualine_a_terminal xxx gui=bold guifg=#1e1e2e guibg=#a6e3a1
        -- lualine_b_terminal                                                                { bg="#45475a", fg="#94e2d5", }, -- lualine_b_terminal xxx guifg=#94e2d5 guibg=#45475a
        -- lualine_a_insert                                                                  { bg="#a6e3a1", gui="bold", fg="#1e1e2e", }, -- lualine_a_insert xxx gui=bold guifg=#1e1e2e guibg=#a6e3a1
        -- lualine_b_insert                                                                  { bg="#45475a", fg="#94e2d5", }, -- lualine_b_insert xxx guifg=#94e2d5 guibg=#45475a
        -- lualine_c_normal                                                                  { bg="#181825", fg="#cdd6f4", }, -- lualine_c_normal xxx guifg=#cdd6f4 guibg=#181825
        -- lualine_a_normal                                                                  { bg="#89b4fa", gui="bold", fg="#181825", }, -- lualine_a_normal xxx gui=bold guifg=#181825 guibg=#89b4fa
        -- lualine_b_normal                                                                  { bg="#45475a", fg="#89b4fa", }, -- lualine_b_normal xxx guifg=#89b4fa guibg=#45475a
        -- lualine_a_replace                                                                 { bg="#f38ba8", gui="bold", fg="#1e1e2e", }, -- lualine_a_replace xxx gui=bold guifg=#1e1e2e guibg=#f38ba8
        -- lualine_b_replace                                                                 { bg="#45475a", fg="#f38ba8", }, -- lualine_b_replace xxx guifg=#f38ba8 guibg=#45475a
        -- lualine_x_2_normal                                                                { bg="#181825", fg="#cba6f7", }, -- lualine_x_2_normal xxx guifg=#cba6f7 guibg=#181825
        -- lualine_x_2_insert                                                                { bg="#181825", fg="#cba6f7", }, -- lualine_x_2_insert xxx guifg=#cba6f7 guibg=#181825
        -- lualine_x_2_visual                                                                { bg="#181825", fg="#cba6f7", }, -- lualine_x_2_visual xxx guifg=#cba6f7 guibg=#181825
        -- lualine_x_2_replace                                                               { bg="#181825", fg="#cba6f7", }, -- lualine_x_2_replace xxx guifg=#cba6f7 guibg=#181825
        -- lualine_x_2_command                                                               { bg="#181825", fg="#cba6f7", }, -- lualine_x_2_command xxx guifg=#cba6f7 guibg=#181825
        -- lualine_x_2_terminal                                                              { bg="#181825", fg="#cba6f7", }, -- lualine_x_2_terminal xxx guifg=#cba6f7 guibg=#181825
        -- lualine_x_2_inactive                                                              { bg="#181825", fg="#cba6f7", }, -- lualine_x_2_inactive xxx guifg=#cba6f7 guibg=#181825
        -- lualine_x_3_normal                                                                { bg="#181825", fg="#f5e0dc", }, -- lualine_x_3_normal xxx guifg=#f5e0dc guibg=#181825
        -- lualine_x_3_insert                                                                { bg="#181825", fg="#f5e0dc", }, -- lualine_x_3_insert xxx guifg=#f5e0dc guibg=#181825
        -- lualine_x_3_visual                                                                { bg="#181825", fg="#f5e0dc", }, -- lualine_x_3_visual xxx guifg=#f5e0dc guibg=#181825
        -- lualine_x_3_replace                                                               { bg="#181825", fg="#f5e0dc", }, -- lualine_x_3_replace xxx guifg=#f5e0dc guibg=#181825
        -- lualine_x_3_command                                                               { bg="#181825", fg="#f5e0dc", }, -- lualine_x_3_command xxx guifg=#f5e0dc guibg=#181825
        -- lualine_x_3_terminal                                                              { bg="#181825", fg="#f5e0dc", }, -- lualine_x_3_terminal xxx guifg=#f5e0dc guibg=#181825
        -- lualine_x_3_inactive                                                              { bg="#181825", fg="#f5e0dc", }, -- lualine_x_3_inactive xxx guifg=#f5e0dc guibg=#181825
        -- lualine_x_5_normal                                                                { bg="#181825", fg="#f5c2e7", }, -- lualine_x_5_normal xxx guifg=#f5c2e7 guibg=#181825
        -- lualine_x_5_insert                                                                { bg="#181825", fg="#f5c2e7", }, -- lualine_x_5_insert xxx guifg=#f5c2e7 guibg=#181825
        -- lualine_x_5_visual                                                                { bg="#181825", fg="#f5c2e7", }, -- lualine_x_5_visual xxx guifg=#f5c2e7 guibg=#181825
        -- lualine_x_5_replace                                                               { bg="#181825", fg="#f5c2e7", }, -- lualine_x_5_replace xxx guifg=#f5c2e7 guibg=#181825
        -- lualine_x_5_command                                                               { bg="#181825", fg="#f5c2e7", }, -- lualine_x_5_command xxx guifg=#f5c2e7 guibg=#181825
        -- lualine_x_5_terminal                                                              { bg="#181825", fg="#f5c2e7", }, -- lualine_x_5_terminal xxx guifg=#f5c2e7 guibg=#181825
        -- lualine_x_5_inactive                                                              { bg="#181825", fg="#f5c2e7", }, -- lualine_x_5_inactive xxx guifg=#f5c2e7 guibg=#181825
        -- lualine_x_diff_added_normal                                                       { bg="#181825", fg="#a6e3a1", }, -- lualine_x_diff_added_normal xxx guifg=#a6e3a1 guibg=#181825
        -- lualine_x_diff_added_insert                                                       { bg="#181825", fg="#a6e3a1", }, -- lualine_x_diff_added_insert xxx guifg=#a6e3a1 guibg=#181825
        -- lualine_x_diff_added_visual                                                       { bg="#181825", fg="#a6e3a1", }, -- lualine_x_diff_added_visual xxx guifg=#a6e3a1 guibg=#181825
        -- lualine_x_diff_added_replace                                                      { bg="#181825", fg="#a6e3a1", }, -- lualine_x_diff_added_replace xxx guifg=#a6e3a1 guibg=#181825
        -- lualine_x_diff_added_command                                                      { bg="#181825", fg="#a6e3a1", }, -- lualine_x_diff_added_command xxx guifg=#a6e3a1 guibg=#181825
        -- lualine_x_diff_added_terminal                                                     { bg="#181825", fg="#a6e3a1", }, -- lualine_x_diff_added_terminal xxx guifg=#a6e3a1 guibg=#181825
        -- lualine_x_diff_added_inactive                                                     { bg="#181825", fg="#a6e3a1", }, -- lualine_x_diff_added_inactive xxx guifg=#a6e3a1 guibg=#181825
        -- lualine_x_diff_modified_normal                                                    { bg="#181825", fg="#f9e2af", }, -- lualine_x_diff_modified_normal xxx guifg=#f9e2af guibg=#181825
        -- lualine_x_diff_modified_insert                                                    { bg="#181825", fg="#f9e2af", }, -- lualine_x_diff_modified_insert xxx guifg=#f9e2af guibg=#181825
        -- lualine_x_diff_modified_visual                                                    { bg="#181825", fg="#f9e2af", }, -- lualine_x_diff_modified_visual xxx guifg=#f9e2af guibg=#181825
        -- lualine_x_diff_modified_replace                                                   { bg="#181825", fg="#f9e2af", }, -- lualine_x_diff_modified_replace xxx guifg=#f9e2af guibg=#181825
        -- lualine_x_diff_modified_command                                                   { bg="#181825", fg="#f9e2af", }, -- lualine_x_diff_modified_command xxx guifg=#f9e2af guibg=#181825
        -- lualine_x_diff_modified_terminal                                                  { bg="#181825", fg="#f9e2af", }, -- lualine_x_diff_modified_terminal xxx guifg=#f9e2af guibg=#181825
        -- lualine_x_diff_modified_inactive                                                  { bg="#181825", fg="#f9e2af", }, -- lualine_x_diff_modified_inactive xxx guifg=#f9e2af guibg=#181825
        -- lualine_x_diff_removed_normal                                                     { bg="#181825", fg="#f38ba8", }, -- lualine_x_diff_removed_normal xxx guifg=#f38ba8 guibg=#181825
        -- lualine_x_diff_removed_insert                                                     { bg="#181825", fg="#f38ba8", }, -- lualine_x_diff_removed_insert xxx guifg=#f38ba8 guibg=#181825
        -- lualine_x_diff_removed_visual                                                     { bg="#181825", fg="#f38ba8", }, -- lualine_x_diff_removed_visual xxx guifg=#f38ba8 guibg=#181825
        -- lualine_x_diff_removed_replace                                                    { bg="#181825", fg="#f38ba8", }, -- lualine_x_diff_removed_replace xxx guifg=#f38ba8 guibg=#181825
        -- lualine_x_diff_removed_command                                                    { bg="#181825", fg="#f38ba8", }, -- lualine_x_diff_removed_command xxx guifg=#f38ba8 guibg=#181825
        -- lualine_x_diff_removed_terminal                                                   { bg="#181825", fg="#f38ba8", }, -- lualine_x_diff_removed_terminal xxx guifg=#f38ba8 guibg=#181825
        -- lualine_x_diff_removed_inactive                                                   { bg="#181825", fg="#f38ba8", }, -- lualine_x_diff_removed_inactive xxx guifg=#f38ba8 guibg=#181825
        -- lualine_c_diagnostics_error_normal                                                { bg="#181825", fg="#f38ba8", }, -- lualine_c_diagnostics_error_normal xxx guifg=#f38ba8 guibg=#181825
        -- lualine_c_diagnostics_error_insert                                                { bg="#181825", fg="#f38ba8", }, -- lualine_c_diagnostics_error_insert xxx guifg=#f38ba8 guibg=#181825
        -- lualine_c_diagnostics_error_visual                                                { bg="#181825", fg="#f38ba8", }, -- lualine_c_diagnostics_error_visual xxx guifg=#f38ba8 guibg=#181825
        -- lualine_c_diagnostics_error_replace                                               { bg="#181825", fg="#f38ba8", }, -- lualine_c_diagnostics_error_replace xxx guifg=#f38ba8 guibg=#181825
        -- lualine_c_diagnostics_error_command                                               { bg="#181825", fg="#f38ba8", }, -- lualine_c_diagnostics_error_command xxx guifg=#f38ba8 guibg=#181825
        -- lualine_c_diagnostics_error_terminal                                              { bg="#181825", fg="#f38ba8", }, -- lualine_c_diagnostics_error_terminal xxx guifg=#f38ba8 guibg=#181825
        -- lualine_c_diagnostics_error_inactive                                              { bg="#181825", fg="#f38ba8", }, -- lualine_c_diagnostics_error_inactive xxx guifg=#f38ba8 guibg=#181825
        -- lualine_c_diagnostics_warn_normal                                                 { bg="#181825", fg="#f9e2af", }, -- lualine_c_diagnostics_warn_normal xxx guifg=#f9e2af guibg=#181825
        -- lualine_c_diagnostics_warn_insert                                                 { bg="#181825", fg="#f9e2af", }, -- lualine_c_diagnostics_warn_insert xxx guifg=#f9e2af guibg=#181825
        -- lualine_c_diagnostics_warn_visual                                                 { bg="#181825", fg="#f9e2af", }, -- lualine_c_diagnostics_warn_visual xxx guifg=#f9e2af guibg=#181825
        -- lualine_c_diagnostics_warn_replace                                                { bg="#181825", fg="#f9e2af", }, -- lualine_c_diagnostics_warn_replace xxx guifg=#f9e2af guibg=#181825
        -- lualine_c_diagnostics_warn_command                                                { bg="#181825", fg="#f9e2af", }, -- lualine_c_diagnostics_warn_command xxx guifg=#f9e2af guibg=#181825
        -- lualine_c_diagnostics_warn_terminal                                               { bg="#181825", fg="#f9e2af", }, -- lualine_c_diagnostics_warn_terminal xxx guifg=#f9e2af guibg=#181825
        -- lualine_c_diagnostics_warn_inactive                                               { bg="#181825", fg="#f9e2af", }, -- lualine_c_diagnostics_warn_inactive xxx guifg=#f9e2af guibg=#181825
        -- lualine_c_diagnostics_info_normal                                                 { bg="#181825", fg="#89dceb", }, -- lualine_c_diagnostics_info_normal xxx guifg=#89dceb guibg=#181825
        -- lualine_c_diagnostics_info_insert                                                 { bg="#181825", fg="#89dceb", }, -- lualine_c_diagnostics_info_insert xxx guifg=#89dceb guibg=#181825
        -- lualine_c_diagnostics_info_visual                                                 { bg="#181825", fg="#89dceb", }, -- lualine_c_diagnostics_info_visual xxx guifg=#89dceb guibg=#181825
        -- lualine_c_diagnostics_info_replace                                                { bg="#181825", fg="#89dceb", }, -- lualine_c_diagnostics_info_replace xxx guifg=#89dceb guibg=#181825
        -- lualine_c_diagnostics_info_command                                                { bg="#181825", fg="#89dceb", }, -- lualine_c_diagnostics_info_command xxx guifg=#89dceb guibg=#181825
        -- lualine_c_diagnostics_info_terminal                                               { bg="#181825", fg="#89dceb", }, -- lualine_c_diagnostics_info_terminal xxx guifg=#89dceb guibg=#181825
        -- lualine_c_diagnostics_info_inactive                                               { bg="#181825", fg="#89dceb", }, -- lualine_c_diagnostics_info_inactive xxx guifg=#89dceb guibg=#181825
        -- lualine_c_diagnostics_hint_normal                                                 { bg="#181825", fg="#94e2d5", }, -- lualine_c_diagnostics_hint_normal xxx guifg=#94e2d5 guibg=#181825
        -- lualine_c_diagnostics_hint_insert                                                 { bg="#181825", fg="#94e2d5", }, -- lualine_c_diagnostics_hint_insert xxx guifg=#94e2d5 guibg=#181825
        -- lualine_c_diagnostics_hint_visual                                                 { bg="#181825", fg="#94e2d5", }, -- lualine_c_diagnostics_hint_visual xxx guifg=#94e2d5 guibg=#181825
        -- lualine_c_diagnostics_hint_replace                                                { bg="#181825", fg="#94e2d5", }, -- lualine_c_diagnostics_hint_replace xxx guifg=#94e2d5 guibg=#181825
        -- lualine_c_diagnostics_hint_command                                                { bg="#181825", fg="#94e2d5", }, -- lualine_c_diagnostics_hint_command xxx guifg=#94e2d5 guibg=#181825
        -- lualine_c_diagnostics_hint_terminal                                               { bg="#181825", fg="#94e2d5", }, -- lualine_c_diagnostics_hint_terminal xxx guifg=#94e2d5 guibg=#181825
        -- lualine_c_diagnostics_hint_inactive                                               { bg="#181825", fg="#94e2d5", }, -- lualine_c_diagnostics_hint_inactive xxx guifg=#94e2d5 guibg=#181825
        -- lualine_c_filetype_DevIconDefault_normal                                          { bg="#181825", fg="#6d8086", }, -- lualine_c_filetype_DevIconDefault_normal xxx guifg=#6d8086 guibg=#181825
        -- lualine_c_filetype_DevIconDefault_insert                                          { bg="#181825", fg="#6d8086", }, -- lualine_c_filetype_DevIconDefault_insert xxx guifg=#6d8086 guibg=#181825
        -- lualine_c_filetype_DevIconDefault_visual                                          { bg="#181825", fg="#6d8086", }, -- lualine_c_filetype_DevIconDefault_visual xxx guifg=#6d8086 guibg=#181825
        -- lualine_c_filetype_DevIconDefault_replace                                         { bg="#181825", fg="#6d8086", }, -- lualine_c_filetype_DevIconDefault_replace xxx guifg=#6d8086 guibg=#181825
        -- lualine_c_filetype_DevIconDefault_command                                         { bg="#181825", fg="#6d8086", }, -- lualine_c_filetype_DevIconDefault_command xxx guifg=#6d8086 guibg=#181825
        -- lualine_c_filetype_DevIconDefault_terminal                                        { bg="#181825", fg="#6d8086", }, -- lualine_c_filetype_DevIconDefault_terminal xxx guifg=#6d8086 guibg=#181825
        -- lualine_c_filetype_DevIconDefault_inactive                                        { bg="#181825", fg="#6d8086", }, -- lualine_c_filetype_DevIconDefault_inactive xxx guifg=#6d8086 guibg=#181825
        -- lualine_transitional_lualine_a_insert_to_lualine_b_insert                         { bg="#45475a", fg="#a6e3a1", }, -- lualine_transitional_lualine_a_insert_to_lualine_b_insert xxx guifg=#a6e3a1 guibg=#45475a
        -- lualine_transitional_lualine_b_insert_to_lualine_c_filetype_DevIconDefault_insert { bg="#181825", fg="#45475a", }, -- lualine_transitional_lualine_b_insert_to_lualine_c_filetype_DevIconDefault_insert xxx guifg=#45475a guibg=#181825
        -- lualine_transitional_lualine_b_insert_to_lualine_x_5_insert                       { bg="#181825", fg="#45475a", }, -- lualine_transitional_lualine_b_insert_to_lualine_x_5_insert xxx guifg=#45475a guibg=#181825
        -- lualine_c_filetype_DevIconPy_normal                                               { bg="#181825", fg="#ffbc03", }, -- lualine_c_filetype_DevIconPy_normal xxx guifg=#ffbc03 guibg=#181825
        -- lualine_c_filetype_DevIconPy_insert                                               { bg="#181825", fg="#ffbc03", }, -- lualine_c_filetype_DevIconPy_insert xxx guifg=#ffbc03 guibg=#181825
        -- lualine_c_filetype_DevIconPy_visual                                               { bg="#181825", fg="#ffbc03", }, -- lualine_c_filetype_DevIconPy_visual xxx guifg=#ffbc03 guibg=#181825
        -- lualine_c_filetype_DevIconPy_replace                                              { bg="#181825", fg="#ffbc03", }, -- lualine_c_filetype_DevIconPy_replace xxx guifg=#ffbc03 guibg=#181825
        -- lualine_c_filetype_DevIconPy_command                                              { bg="#181825", fg="#ffbc03", }, -- lualine_c_filetype_DevIconPy_command xxx guifg=#ffbc03 guibg=#181825
        -- lualine_c_filetype_DevIconPy_terminal                                             { bg="#181825", fg="#ffbc03", }, -- lualine_c_filetype_DevIconPy_terminal xxx guifg=#ffbc03 guibg=#181825
        -- lualine_c_filetype_DevIconPy_inactive                                             { bg="#181825", fg="#ffbc03", }, -- lualine_c_filetype_DevIconPy_inactive xxx guifg=#ffbc03 guibg=#181825
        -- lualine_transitional_lualine_b_normal_to_lualine_c_filetype_DevIconPy_normal      { bg="#181825", fg="#45475a", }, -- lualine_transitional_lualine_b_normal_to_lualine_c_filetype_DevIconPy_normal xxx guifg=#45475a guibg=#181825
        -- lualine_transitional_lualine_b_normal_to_lualine_x_5_normal                       { bg="#181825", fg="#45475a", }, -- lualine_transitional_lualine_b_normal_to_lualine_x_5_normal xxx guifg=#45475a guibg=#181825
        -- lualine_transitional_lualine_b_normal_to_lualine_x_diff_removed_normal            { bg="#181825", fg="#45475a", }, -- lualine_transitional_lualine_b_normal_to_lualine_x_diff_removed_normal xxx guifg=#45475a guibg=#181825
        -- lualine_transitional_lualine_b_normal_to_lualine_c_diagnostics_error_normal       { bg="#181825", fg="#45475a", }, -- lualine_transitional_lualine_b_normal_to_lualine_c_diagnostics_error_normal xxx guifg=#45475a guibg=#181825
        -- lualine_transitional_lualine_b_command_to_lualine_c_diagnostics_error_command     { bg="#181825", fg="#45475a", }, -- lualine_transitional_lualine_b_command_to_lualine_c_diagnostics_error_command xxx guifg=#45475a guibg=#181825
        -- lualine_transitional_lualine_b_command_to_lualine_x_diff_removed_command          { bg="#181825", fg="#45475a", }, -- lualine_transitional_lualine_b_command_to_lualine_x_diff_removed_command xxx guifg=#45475a guibg=#181825
        -- NoiceFormatLevelTrace                                                             { }, -- NoiceFormatLevelTrace xxx cterm= gui=
        -- NoiceFormatLevelDebug                                                             { }, -- NoiceFormatLevelDebug xxx cterm= gui=
        -- NoiceFormatTitle                                                                  { }, -- NoiceFormatTitle xxx cterm= gui=
        -- NoiceFormatConfirmDefault                                                         { }, -- NoiceFormatConfirmDefault xxx cterm= gui=
        -- NoiceFormatConfirm                                                                { }, -- NoiceFormatConfirm xxx cterm= gui=
        -- NoiceFormatDate                                                                   { }, -- NoiceFormatDate xxx cterm= gui=
        -- NoiceFormatKind                                                                   { }, -- NoiceFormatKind xxx cterm= gui=
        -- NoiceFormatEvent                                                                  { }, -- NoiceFormatEvent xxx cterm= gui=
        -- NoiceFormatProgressTodo                                                           { }, -- NoiceFormatProgressTodo xxx cterm= gui=
        -- NoiceFormatProgressDone                                                           { bg="#3e5767", fg="#cdd6f4", }, -- NoiceFormatProgressDone xxx cterm= gui= guifg=#cdd6f4 guibg=#3e5767
        -- NoiceSplitBorder                                                                  { }, -- NoiceSplitBorder xxx cterm= gui=
        -- NoiceSplit                                                                        { }, -- NoiceSplit     xxx cterm= gui=
        -- NoiceScrollbarThumb                                                               { }, -- NoiceScrollbarThumb xxx cterm= gui=
        -- NoiceScrollbar                                                                    { }, -- NoiceScrollbar xxx cterm= gui=
        -- NoicePopupmenuSelected                                                            { }, -- NoicePopupmenuSelected xxx cterm= gui=
        -- NoicePopupmenuMatch                                                               { }, -- NoicePopupmenuMatch xxx cterm= gui=
        -- NoicePopupmenuBorder                                                              { }, -- NoicePopupmenuBorder xxx cterm= gui=
        -- NoicePopupmenu                                                                    { }, -- NoicePopupmenu xxx cterm= gui=
        -- NoicePopupBorder                                                                  { }, -- NoicePopupBorder xxx cterm= gui=
        -- NoiceCursor                                                                       { }, -- NoiceCursor    xxx cterm= gui=
        -- NoiceMini                                                                         { }, -- NoiceMini      xxx cterm= gui=
        -- NoiceConfirm                                                                      { }, -- NoiceConfirm   xxx cterm= gui=
        -- NoiceCmdlinePopupBorderSearch                                                     { }, -- NoiceCmdlinePopupBorderSearch xxx cterm= gui=
        -- NoiceCmdlinePopupTitle                                                            { }, -- NoiceCmdlinePopupTitle xxx cterm= gui=
        -- NoiceCmdlinePopup                                                                 { }, -- NoiceCmdlinePopup xxx cterm= gui=
        -- NoiceCmdlineIconSearch                                                            { }, -- NoiceCmdlineIconSearch xxx cterm= gui=
        -- NoiceConfirmBorder                                                                { }, -- NoiceConfirmBorder xxx cterm= gui=
        -- NoiceCompletionItemKindEnum                                                       { }, -- NoiceCompletionItemKindEnum xxx cterm= gui=
        -- NoiceCompletionItemKindDefault                                                    { }, -- NoiceCompletionItemKindDefault xxx cterm= gui=
        -- NoiceCompletionItemKindVariable                                                   { }, -- NoiceCompletionItemKindVariable xxx cterm= gui=
        -- NoiceCompletionItemKindFile                                                       { }, -- NoiceCompletionItemKindFile xxx cterm= gui=
        -- NoiceCompletionItemKindField                                                      { }, -- NoiceCompletionItemKindField xxx cterm= gui=
        -- NoiceCompletionItemKindUnit                                                       { }, -- NoiceCompletionItemKindUnit xxx cterm= gui=
        -- NoiceCompletionItemKindEnumMember                                                 { }, -- NoiceCompletionItemKindEnumMember xxx cterm= gui=
        -- NoiceCompletionItemKindText                                                       { }, -- NoiceCompletionItemKindText xxx cterm= gui=
        -- NoiceCompletionItemKindFolder                                                     { }, -- NoiceCompletionItemKindFolder xxx cterm= gui=
        -- NoiceCompletionItemKindConstant                                                   { }, -- NoiceCompletionItemKindConstant xxx cterm= gui=
        -- NoiceCompletionItemKindProperty                                                   { }, -- NoiceCompletionItemKindProperty xxx cterm= gui=
        -- NoiceCompletionItemKindValue                                                      { }, -- NoiceCompletionItemKindValue xxx cterm= gui=
        -- NoiceCompletionItemKindKeyword                                                    { }, -- NoiceCompletionItemKindKeyword xxx cterm= gui=
        -- NoiceCompletionItemKindStruct                                                     { }, -- NoiceCompletionItemKindStruct xxx cterm= gui=
        -- NoiceCompletionItemKindModule                                                     { }, -- NoiceCompletionItemKindModule xxx cterm= gui=
        -- NoiceCompletionItemKindInterface                                                  { }, -- NoiceCompletionItemKindInterface xxx cterm= gui=
        -- NoiceCompletionItemKindConstructor                                                { }, -- NoiceCompletionItemKindConstructor xxx cterm= gui=
        -- NoiceCompletionItemKindSnippet                                                    { }, -- NoiceCompletionItemKindSnippet xxx cterm= gui=
        -- NoiceCompletionItemKindClass                                                      { }, -- NoiceCompletionItemKindClass xxx cterm= gui=
        -- NoiceCompletionItemKindMethod                                                     { }, -- NoiceCompletionItemKindMethod xxx cterm= gui=
        -- NoiceCompletionItemKindFunction                                                   { }, -- NoiceCompletionItemKindFunction xxx cterm= gui=
        -- NoiceCompletionItemKindColor                                                      { }, -- NoiceCompletionItemKindColor xxx cterm= gui=
        -- NoiceLspProgressClient                                                            { }, -- NoiceLspProgressClient xxx cterm= gui=
        -- NoiceLspProgressTitle                                                             { }, -- NoiceLspProgressTitle xxx cterm= gui=
        -- NoiceLspProgressSpinner                                                           { }, -- NoiceLspProgressSpinner xxx cterm= gui=
        -- NoiceFormatLevelError                                                             { }, -- NoiceFormatLevelError xxx cterm= gui=
        -- NoiceFormatLevelWarn                                                              { }, -- NoiceFormatLevelWarn xxx cterm= gui=
        -- NoiceFormatLevelInfo                                                              { }, -- NoiceFormatLevelInfo xxx cterm= gui=
        -- NoiceFormatLevelOff                                                               { }, -- NoiceFormatLevelOff xxx cterm= gui=
        -- NoiceCmdlinePopupBorderCmdline                                                    { }, -- NoiceCmdlinePopupBorderCmdline xxx cterm= gui=
        -- NoiceCmdlinePopupBorder                                                           { }, -- NoiceCmdlinePopupBorder xxx cterm= gui=
        -- NoiceCmdlineIconInput                                                             { }, -- NoiceCmdlineIconInput xxx cterm= gui=
        -- NoiceCmdlineIcon                                                                  { }, -- NoiceCmdlineIcon xxx cterm= gui=
        -- NoiceCmdlinePopupBorderInput                                                      { }, -- NoiceCmdlinePopupBorderInput xxx cterm= gui=
        -- NoiceCmdlineIconCalculator                                                        { }, -- NoiceCmdlineIconCalculator xxx cterm= gui=
        -- NoiceCmdlinePopupBorderCalculator                                                 { }, -- NoiceCmdlinePopupBorderCalculator xxx cterm= gui=
        -- NoiceCmdlineIconFilter                                                            { }, -- NoiceCmdlineIconFilter xxx cterm= gui=
        -- NoiceCmdlinePopupBorderFilter                                                     { }, -- NoiceCmdlinePopupBorderFilter xxx cterm= gui=
        -- NoiceCmdlineIconLua                                                               { }, -- NoiceCmdlineIconLua xxx cterm= gui=
        -- NoiceCmdlinePopupBorderLua                                                        { }, -- NoiceCmdlinePopupBorderLua xxx cterm= gui=
        -- NoiceCmdlineIconHelp                                                              { }, -- NoiceCmdlineIconHelp xxx cterm= gui=
        -- NoiceCmdline                                                                      { }, -- NoiceCmdline   xxx cterm= gui=
        -- NoiceCmdlineIconCmdline                                                           { }, -- NoiceCmdlineIconCmdline xxx cterm= gui=
        -- NoiceCmdlinePopupBorderHelp                                                       { }, -- NoiceCmdlinePopupBorderHelp xxx cterm= gui=
        -- NoiceVirtualText                                                                  { }, -- NoiceVirtualText xxx cterm= gui=
        -- NoicePopup                                                                        { }, -- NoicePopup     xxx cterm= gui=
        -- NoiceHiddenCursor                                                                 { blend=100, gui="nocombine", }, -- NoiceHiddenCursor xxx cterm=nocombine gui=nocombine blend=100
        -- lualine_transitional_lualine_a_normal_to_lualine_b_normal                         { bg="#45475a", fg="#89b4fa", }, -- lualine_transitional_lualine_a_normal_to_lualine_b_normal xxx guifg=#89b4fa guibg=#45475a
        -- lualine_transitional_lualine_b_normal_to_lualine_c_normal                         { bg="#181825", fg="#45475a", }, -- lualine_transitional_lualine_b_normal_to_lualine_c_normal xxx guifg=#45475a guibg=#181825
        -- lualine_transitional_lualine_a_command_to_lualine_b_command                       { bg="#45475a", fg="#fab387", }, -- lualine_transitional_lualine_a_command_to_lualine_b_command xxx guifg=#fab387 guibg=#45475a
        -- lualine_transitional_lualine_b_command_to_lualine_c_normal                        { bg="#181825", fg="#45475a", }, -- lualine_transitional_lualine_b_command_to_lualine_c_normal xxx guifg=#45475a guibg=#181825
        -- CmpItemAbbrDefault                                                                { fg="#9399b2", }, -- CmpItemAbbrDefault xxx guifg=#9399b2
        -- CmpItemAbbrDeprecatedDefault                                                      { fg="#ffdfaf", }, -- CmpItemAbbrDeprecatedDefault xxx guifg=#ffdfaf
        -- CmpItemAbbrMatchDefault                                                           { fg="#9399b2", }, -- CmpItemAbbrMatchDefault xxx guifg=#9399b2
        -- CmpItemAbbrMatchFuzzyDefault                                                      { fg="#9399b2", }, -- CmpItemAbbrMatchFuzzyDefault xxx guifg=#9399b2
        -- CmpItemKindDefault                                                                { fg="#f5c2e7", }, -- CmpItemKindDefault xxx guifg=#f5c2e7
        -- CmpItemMenuDefault                                                                { fg="#9399b2", }, -- CmpItemMenuDefault xxx guifg=#9399b2
    }
end)
return theme
