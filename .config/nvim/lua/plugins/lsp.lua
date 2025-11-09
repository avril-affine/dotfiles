return {
    -- mason: portable package manager for LSP servers, DAP servers, linters, and formatters
    {
        "mason-org/mason.nvim",
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            })
        end,
    },

    -- mason-lspconfig: bridge between mason and lspconfig
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            ensure_installed = {
                "lua_ls",
                "ts_ls",
                "html",
                "pylsp",
                "rust_analyzer",
                "vimls",
                "zls",
                "elixirls",
                "ccls",
                "sourcekit",
                "gleam",
                "pyrefly",
            },
            automatic_installation = true,
        },
    },

    -- lsp servers
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "LazyVim/LazyVim",
            {
                "folke/lazydev.nvim",
                ft = "lua", -- only load on lua files
                opts = {
                    library = {
                        -- See the configuration section for more details
                        -- Load luvit types when the `vim.uv` word is found
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            },
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        keys = {
            { "K", function() vim.lsp.buf.hover() end, desc = "LSP hover" },
            { "<leader>d", function() vim.lsp.buf.definition() end, desc =  "goto definition" },
            { "<leader>i", function() vim.lsp.buf.implementation() end, desc = "goto implementation" },
            { "<leader>D", function() vim.lsp.buf.type_definition() end, desc = "goto type definition" },
            { "<leader>r", function() vim.lsp.buf.references() end, desc = "find references" },
            { "<leader>e", function() vim.diagnostic.open_float() end, desc = "open diagnostics" },
        },
        opts = {
            diagnostics = {
                underline = true,
                update_in_insert = false,
                virtual_text = false,
                severity_sort = true,
            },
            servers = {
                pylsp = {
                    settings = {
                        pylsp = {
                            configurationSources = { "flake8" },
                            plugins = {
                                pycodestyle = { enabled = false },
                                pyflakes = { enabled = false },
                                mccabe = { enabled = false },
                                yapf = { enabled = false },
                                flake8 = { enabled = true },
                                pylsp_mypy = { enabled = true },
                                rope_completion = {
                                    enabled = true,
                                    eager = true,
                                },
                            },
                        },
                    },
                },
                -- pyrefly = {},
                -- ty = {},
                rust_analyzer = {
                    settings = {
                        ["rust-analyzer"] = {
                            procMacro = { enable = true },
                            cargo = { allFeatures = true },
                            checkOnSave = {
                                command = "clippy",
                                extraArgs = { "--no-deps" },
                            },
                        },
                    },
                },
                ts_ls = {},
                html = {},
                lua_ls = {
                    -- enabled = false,
                    single_file_support = true,
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
                                -- enable = false,
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
                },
                vimls = {},
                zls = {},
                elixirls = {},
                ccls = {
                  init_options = {
                    cache = {
                      directory = ".ccls-cache";
                    };
                  },
                },
                sourcekit = {},
                gleam = {},
            },
            setup = {},
        },
        config = function(_, opts)
            -- Add custom pyrefly LSP configuration
            local lspconfig = require("lspconfig")
            local configs = require("lspconfig.configs")

            if not configs.pyrefly then
                configs.pyrefly = {
                    default_config = {
                        cmd = { "pyrefly", "lsp" },
                        filetypes = { "python" },
                        root_dir = lspconfig.util.root_pattern("pyproject.toml", "setup.py", ".git"),
                        settings = {},
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
                                end, 15000) -- 15 second delay to allow indexing to complete
                            end
                        end,
                    },
                }
            end

            if not configs.ty then
                configs.ty = {
                    default_config = {
                        cmd = { "ty", "server" },
                        filetypes = { "python" },
                        root_dir = lspconfig.util.root_pattern("pyproject.toml", "setup.py", ".git"),
                        settings = {},
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
                                end, 15000) -- 15 second delay to allow indexing to complete
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
                    },
                }
            end

            -- Setup semshi-like semantic highlighting colors
            local function setup_semantic_highlights()
                -- Semshi-inspired highlight groups for semantic tokens
                vim.api.nvim_set_hl(0, '@lsp.type.variable.python', { fg = '#ff875f' })  -- Local variables (orange)
                vim.api.nvim_set_hl(0, '@lsp.type.parameter.python', { fg = '#5fafff' })  -- Parameters (blue)
                vim.api.nvim_set_hl(0, '@lsp.type.function.python', { fg = '#00ffaf' })  -- Functions (cyan)
                vim.api.nvim_set_hl(0, '@lsp.type.method.python', { fg = '#00ffaf' })  -- Methods (cyan)
                vim.api.nvim_set_hl(0, '@lsp.type.class.python', { fg = '#ffaf00', bold = true })  -- Classes (gold, bold)
                vim.api.nvim_set_hl(0, '@lsp.type.property.python', { fg = '#00ffaf' })  -- Attributes (cyan)
                vim.api.nvim_set_hl(0, '@lsp.type.namespace.python', { fg = '#ffaf00', bold = true })  -- Imports (gold, bold)
                vim.api.nvim_set_hl(0, '@lsp.mod.builtin.python', { fg = '#ff5fff' })  -- Builtins (magenta)
                vim.api.nvim_set_hl(0, '@lsp.mod.global.python', { fg = '#ffaf00' })  -- Globals (gold)

                -- Self/cls highlighting
                vim.api.nvim_set_hl(0, '@lsp.typemod.parameter.selfParameter.python', { fg = '#b2b2b2' })  -- self (gray)

                -- Unused parameters
                vim.api.nvim_set_hl(0, '@lsp.typemod.parameter.unused.python', { fg = '#87d7ff', underline = true })  -- Unused params
            end

            -- Apply semantic highlights on ColorScheme changes
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = setup_semantic_highlights,
            })

            -- Apply highlights now
            setup_semantic_highlights()

            local Util = require("lazyvim.util")
            -- setup formatting and keymaps
            require("lazyvim.util").lsp.on_attach(function(client, buffer)
                -- require("lazyvim.plugins.lsp.format").on_attach(client, buffer)
                require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
            end)

            -- diagnostics
            for name, icon in pairs(require("lazyvim.config").icons.diagnostics) do
                name = "DiagnosticSign" .. name
                vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
            end

            if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
                opts.diagnostics.virtual_text.prefix = vim.fn.has("nvim-0.10.0") == 0 and "●"
                or function(diagnostic)
                    local icons = require("lazyvim.config").icons.diagnostics
                    for d, icon in pairs(icons) do
                        if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
                            return icon
                        end
                    end
                end
            end

            vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

            local servers = opts.servers
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                require("cmp_nvim_lsp").default_capabilities(),
                opts.capabilities or {}
            )

            local function setup(server)
                local server_opts = vim.tbl_deep_extend("force", {
                    capabilities = vim.deepcopy(capabilities),
                }, servers[server] or {})

                if opts.setup[server] then
                    if opts.setup[server](server, server_opts) then
                        return
                    end
                elseif opts.setup["*"] then
                    if opts.setup["*"](server, server_opts) then
                        return
                    end
                end
                require("lspconfig")[server].setup(server_opts)
            end

            -- get all the servers that are available thourgh mason-lspconfig
            local have_mason, mlsp = pcall(require, "mason-lspconfig")
            local all_mslp_servers = {}
            if have_mason then
                all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
            end

            local ensure_installed = {} ---@type string[]
            for server, server_opts in pairs(servers) do
                if server_opts then
                    server_opts = server_opts == true and {} or server_opts
                    -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
                    if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
                        setup(server)
                    else
                        ensure_installed[#ensure_installed + 1] = server
                    end
                end
            end

            if have_mason then
                mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
            end
        end,
    },
    {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        dependencies = { "neovim/nvim-lspconfig" },
        opts = {},
        keys = {
            { "<leader>l", function() require("lsp_lines").toggle() end, desc = "toggle lsp lines", nowait = true, silent = true },
        },
        init = function()
            require("lsp_lines").toggle()
        end,
    },
    {
        "L3MON4D3/LuaSnip",
        keys = function() return {} end,
    },
    {
        "hrsh7th/nvim-cmp",
        version = false, -- last release is way too old
        event = "InsertEnter",
        dependencies = {
            "LazyVim/LazyVim",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-emoji",
        },
        opts = function()
            local luasnip = require("luasnip")
            local cmp = require("cmp")
            local has_words_before = function()
                unpack = unpack or table.unpack
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                if col == 0 then
                    return false
                end
                -- if previous char is not a letter or '.'
                -- TODO: for other filetypes add ':' such as lua
                return (
                    col ~= 0 and
                    vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("[%w%.]") ~= nil
                )
            end
            return {
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = {
                    ["<Tab>"] = cmp.mapping(
                        function(fallback)
                            if cmp.visible() then
                                cmp.select_next_item()
                            elseif luasnip.expand_or_jumpable() then
                                luasnip.expand_or_jump()
                            elseif has_words_before() then
                                cmp.complete()
                            else
                                fallback()
                            end
                        end,
                        {"i", "s"}
                    ),
                    ["<S-Tab>"] = cmp.mapping(
                        function(fallback)
                            if cmp.visible() then
                                cmp.select_prev_item()
                            elseif luasnip.jumpable(-1) then
                                luasnip.jump(-1)
                            else
                                fallback()
                            end
                        end,
                        { "i", "s" }
                    ),
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<ESC>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.mapping.abort()
                            cmp.close()
                        end
                        fallback()
                    end),
                    ["<CR>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            if not cmp.confirm({ select = true }) then
                                fallback()
                            end
                        else
                            fallback()
                        end
                    end),
                    ["<S-CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),
                    ["<C-o>"] = cmp.mapping(  -- <C-i> maps to <Tab> on iterm2  https://github.com/neovim/neovim/issues/24877
                        function(fallback)
                            local resolved_key = vim.fn["copilot#Accept"]()
                            if resolved_key ~= vim.NIL then
                                vim.api.nvim_feedkeys(resolved_key, "n", true)
                            else
                                fallback()
                            end
                        end,
                        {"i", "s"}
                    ),
                },
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "nvim_lsp_signature_help" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            }
        end,
    },
    {
        "folke/noice.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
        },
        event = "VeryLazy",
        opts = {
            presets = {
                lsp_doc_border = true,
                command_palette = true,
            },
            messages = { enabled = false },
            notify = { enabled = false },
            lsp = {
                progress = {
                    enabled = false,
                    -- enabled = true,
                    -- -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
                    -- -- See the section on formatting for more details on how to customize.
                    -- --- @type NoiceFormat|string
                    -- format = "lsp_progress",
                    -- --- @type NoiceFormat|string
                    -- format_done = "lsp_progress_done",
                    -- throttle = 1000 / 30, -- frequency to update lsp progress message
                    -- view = "notify",
                },
                override = {
                    -- override cmp documentation with Noice (needs the other options to work)
                    ["cmp.entry.get_documentation"] = true,
                },
                hover = {
                    enabled = true,
                    silent = false, -- set to true to not show a message if hover is not available
                    view = nil, -- when nil, use defaults from documentation
                    ---@type NoiceViewOptions
                    opts = {}, -- merged with defaults from documentation
                },
                signature = {
                    enabled = true,
                    auto_open = {
                        enabled = true,
                        trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
                        luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
                        throttle = 50, -- Debounce lsp signature help request by 50ms
                    },
                    view = nil, -- when nil, use defaults from documentation
                    ---@type NoiceViewOptions
                    opts = {}, -- merged with defaults from documentation
                },
                -- defaults for hover and signature help
                documentation = {
                    view = "hover",
                    ---@type NoiceViewOptions
                    opts = {
                        replace = true,
                        render = "plain",
                        format = { "{message}" },
                        win_options = { concealcursor = "n", conceallevel = 3 },
                    },
                },
            },
        },
    },
    {
        "github/copilot.vim",
    },
}
