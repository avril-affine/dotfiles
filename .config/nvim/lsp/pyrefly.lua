return {
    cmd = { "pyrefly", "lsp" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", ".git" },
    on_attach = function(client, bufnr)
        -- Disable all capabilities except semantic tokens
        client.server_capabilities.hoverProvider = false
        client.server_capabilities.definitionProvider = false
        client.server_capabilities.declarationProvider = false
        client.server_capabilities.implementationProvider = false
        client.server_capabilities.typeDefinitionProvider = false
        client.server_capabilities.referencesProvider = false
        client.server_capabilities.documentSymbolProvider = false
        client.server_capabilities.workspaceSymbolProvider = false
        client.server_capabilities.codeActionProvider = false
        client.server_capabilities.codeLensProvider = false
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        client.server_capabilities.renameProvider = false
        client.server_capabilities.completionProvider = false
        client.server_capabilities.signatureHelpProvider = false
        client.server_capabilities.documentHighlightProvider = false

        -- Keep semantic tokens only
        if client.server_capabilities.semanticTokensProvider then
            vim.lsp.semantic_tokens.start(bufnr, client.id)

            -- Refresh semantic tokens after a delay to allow pyrefly to finish indexing
            vim.defer_fn(function()
                vim.lsp.semantic_tokens.force_refresh(bufnr)
            end, 15000)
        end
    end,
}
