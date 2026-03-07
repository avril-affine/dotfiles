return {
    cmd = { "ccls" },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_markers = { "compile_commands.json", ".ccls", ".git" },
    init_options = {
        cache = {
            directory = ".ccls-cache",
        },
    },
}
