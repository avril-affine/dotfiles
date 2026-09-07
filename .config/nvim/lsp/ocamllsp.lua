local language_ids = {
    dune = "dune",
    menhir = "ocaml.menhir",
    ocaml = "ocaml",
    ocamlinterface = "ocaml.interface",
    ocamllex = "ocaml.ocamllex",
    reason = "reason",
}

return {
    cmd = { "opam", "exec", "--", "ocamllsp" },
    filetypes = {
        "ocaml",
        "ocamlinterface",
        "ocamllex",
        "menhir",
        "reason",
        "dune",
    },
    root_markers = {
        "dune-project",
        "dune-workspace",
        "esy.json",
        "package.json",
        ".git",
    },
    get_language_id = function(_, filetype)
        return language_ids[filetype] or filetype
    end,
}
