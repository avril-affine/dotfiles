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

    -- mason-lspconfig: auto-install servers + LSP configuration via nvim 0.11 builtins
    {
        "mason-org/mason-lspconfig.nvim",
        lazy = false,
        dependencies = { "mason-org/mason.nvim", "hrsh7th/cmp-nvim-lsp" },
        opts = {
            ensure_installed = {
                "lua_ls",
                "ts_ls",
                "html",
                "basedpyright",
                "rust_analyzer",
                "vimls",
                "zls",
                "elixirls",
                "ccls",
                "sourcekit",
                "gleam",
                -- "pyrefly",
            },
            automatic_installation = true,
        },
        config = function(_, opts)
            require("mason-lspconfig").setup(opts)

            -- Setup semshi-like semantic highlighting colors
            local function setup_semantic_highlights()
                vim.api.nvim_set_hl(0, '@lsp.type.parameter.python', { fg = '#5fafff' })
                vim.api.nvim_set_hl(0, '@lsp.type.function.python', { fg = '#00ffaf' })
                vim.api.nvim_set_hl(0, '@lsp.type.method.python', { fg = '#00ffaf' })
                vim.api.nvim_set_hl(0, '@lsp.type.class.python', { fg = '#ffaf00', bold = true })
                vim.api.nvim_set_hl(0, '@lsp.type.property.python', { fg = '#00ffaf' })
                vim.api.nvim_set_hl(0, '@lsp.type.namespace.python', { fg = '#ffaf00', bold = true })
                vim.api.nvim_set_hl(0, '@lsp.mod.global.python', { fg = '#ffaf00' })
                vim.api.nvim_set_hl(0, 'pythonBuiltin', { fg = '#ff5fff' })
                vim.api.nvim_set_hl(0, '@lsp.mod.builtin.python', { link = 'pythonBuiltin' })
                vim.api.nvim_set_hl(0, '@lsp.typemod.class.defaultLibrary.python', { link = 'pythonBuiltin' })
                vim.api.nvim_set_hl(0, '@lsp.typemod.function.defaultLibrary.python', { link = 'pythonBuiltin' })
                vim.api.nvim_set_hl(0, '@lsp.typemod.parameter.selfParameter.python', { fg = '#b2b2b2' })
                vim.api.nvim_set_hl(0, '@lsp.typemod.parameter.unused.python', { fg = '#87d7ff', underline = true })
            end

            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = setup_semantic_highlights,
            })
            setup_semantic_highlights()

            -- Diagnostics
            vim.diagnostic.config({
                underline = true,
                update_in_insert = false,
                virtual_text = false,
                severity_sort = true,
            })

            local diagnostic_signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
            for name, icon in pairs(diagnostic_signs) do
                local hl = "DiagnosticSign" .. name
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
            end

            -- cmp-nvim-lsp capabilities for all servers
            local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
            if has_cmp then
                vim.lsp.config('*', {
                    capabilities = cmp_lsp.default_capabilities(),
                })
            end

            -- Enable all LSP servers (config files live in lsp/*.lua)
            vim.lsp.enable({
                "lua_ls",
                "basedpyright",
                "rust_analyzer",
                "ts_ls",
                "html",
                "vimls",
                "zls",
                "elixirls",
                "ccls",
                "sourcekit",
                "gleam",
                -- "pyrefly",
                -- "ty",
            })

            -- LSP keymaps via LspAttach (single source of truth)
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local buf = args.buf
                    local o = function(desc) return { buffer = buf, desc = desc } end
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, o("LSP hover"))
                    vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition, o("goto definition"))
                    vim.keymap.set("n", "<leader>i", vim.lsp.buf.implementation, o("goto implementation"))
                    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, o("goto type definition"))
                    vim.keymap.set("n", "<leader>r", vim.lsp.buf.references, o("find references"))
                    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, o("open diagnostics"))
                end,
            })
        end,
    },

    -- lazydev: lua dev setup for neovim plugin development
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },

    {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
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
        version = false,
        event = "InsertEnter",
        dependencies = {
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
                    ["<C-o>"] = cmp.mapping(
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
                },
                override = {
                    ["cmp.entry.get_documentation"] = true,
                },
                hover = {
                    enabled = true,
                    silent = false,
                    view = nil,
                    ---@type NoiceViewOptions
                    opts = {},
                },
                signature = {
                    enabled = true,
                    auto_open = {
                        enabled = true,
                        trigger = true,
                        luasnip = true,
                        throttle = 50,
                    },
                    view = nil,
                    ---@type NoiceViewOptions
                    opts = {},
                },
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
