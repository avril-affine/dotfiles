return {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
    settings = {
        Lua = {
            workspace = {
                checkThirdParty = false,
                library = {
                    [vim.fn.expand("$HOME/.hammerspoon/Spoons/EmmyLua.spoon/annotations")] = true,
                },
            },
            completion = {
                workspaceWord = true,
                callSnippet = "Both",
            },
            misc = {
                parameters = {
                    "--log-level=trace",
                },
            },
            diagnostics = {
                groupSeverity = {
                    strong = "Warning",
                    strict = "Warning",
                },
                groupFileStatus = {
                    ["ambiguity"] = "Opened",
                    ["await"] = "Opened",
                    ["codestyle"] = "None",
                    ["duplicate"] = "Opened",
                    ["global"] = "Opened",
                    ["luadoc"] = "Opened",
                    ["redefined"] = "Opened",
                    ["strict"] = "Opened",
                    ["strong"] = "Opened",
                    ["type-check"] = "Opened",
                    ["unbalanced"] = "Opened",
                    ["unused"] = "Opened",
                },
                unusedLocalExclude = { "_*" },
            },
        },
    },
}
