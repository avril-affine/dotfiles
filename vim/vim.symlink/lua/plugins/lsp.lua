return {
    -- tools
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "stylua",
                "luacheck",
                "shellcheck",
                "shfmt",
                "black",
                "isort",
                "flake8",
            },
        },
        config = function(_, opts)
            require("mason").setup(opts)
            local mr = require("mason-registry")
            local function ensure_installed()
                for _, tool in ipairs(opts.ensure_installed) do
                    local p = mr.get_package(tool)
                    if not p:is_installed() then
                        p:install()
                    end
                end
            end
            if mr.refresh then
                mr.refresh(ensure_installed)
            else
                ensure_installed()
            end
        end,
    },

    -- lsp servers
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "LazyVim/LazyVim",
            { "folke/neoconf.nvim", cmd = "Neoconf", config = true },
            { "folke/neodev.nvim", opts = {} },
            "mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            {
                "hrsh7th/cmp-nvim-lsp",
                dependencies = { "LazyVim/LazyVim" },
                cond = function()
                    return require("lazyvim.util").has("nvim-cmp")
                end,
            },
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
                                rope_completion = {
                                    enabled = true,
                                    eager = true,
                                },
                                flake8 = {
                                    enabled = true,
                                    maxLineLength = 100,
                                },
                            },
                        },
                    },
                },
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
                tsserver = {},
                html = {},
                lua_ls = {
                    -- enabled = false,
                    single_file_support = true,
                    settings = {
                        Lua = {
                            workspace = {
                                checkThirdParty = false,
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
            },
            setup = {},
        },
        config = function(_, opts)
            local Util = require("lazyvim.util")
            -- setup autoformat
            require("lazyvim.plugins.lsp.format").autoformat = opts.autoformat
            -- setup formatting and keymaps
            Util.on_attach(function(client, buffer)
                require("lazyvim.plugins.lsp.format").on_attach(client, buffer)
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

            if Util.lsp_get_config("denols") and Util.lsp_get_config("tsserver") then
                local is_deno = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")
                Util.lsp_disable("tsserver", is_deno)
                Util.lsp_disable("denols", function(root_dir)
                    return not is_deno(root_dir)
                end)
            end
        end,
    },
    {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        dependencies = { "neovim/nvim-lspconfig" },
        keys = {
            { "n", "<leader>l", function() require("lsp_lines").toggle() end, desc = "toggle lsp lines", nowait = true, silent = true },
        },
        init = function()
            require("lsp_lines").setup()
            require("lsp_lines").toggle()
        end,
    },
    {
        "L3M0N4D3/LuaSnip",
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
              return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
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
                mapping = cmp.mapping.preset.insert({
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end, {"i", "s"}),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-u>"] = cmp.mapping.scroll_docs(4),
                    -- ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                    ["<S-CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            }
        end,
    },
}
