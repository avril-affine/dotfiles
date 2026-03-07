return {
    cmd = { "ty", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", ".git" },
    on_attach = function(client, bufnr)
        -- Disable all capabilities except highlighting (semantic tokens & document highlight)
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

        -- Keep document highlight and semantic tokens (highlighting features)
        if client.server_capabilities.semanticTokensProvider then
            vim.lsp.semantic_tokens.start(bufnr, client.id)

            -- Refresh semantic tokens after a delay to allow ty to finish indexing
            vim.defer_fn(function()
                vim.lsp.semantic_tokens.force_refresh(bufnr)
            end, 15000)
        end

        -- Set up document highlight
        if client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = bufnr,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = bufnr,
                callback = vim.lsp.buf.clear_references,
            })
        end
    end,
}
