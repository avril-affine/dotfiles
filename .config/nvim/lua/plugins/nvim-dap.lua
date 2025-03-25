return {
    {
        "mfussenegger/nvim-dap",
        config = function(_, opts)
            -- local dap = require("dap")
            -- local cwd = vim.fn.getcwd()
            vim.fn.sign_define("DapBreakpoint", {text="🛑", texthl="", linehl="", numhl=""})
        end,
        keys = function()
            local dap = require("dap")
            return {
                { "<leader>tc", function() dap.continue() end, desc = "[DAP] continue" },
                { "<leader>tl", function() dap.run_last() end, desc = "[DAP] run last" },
                { "<leader>tD", function() dap.terminate() end, desc = "[DAP] terminate" },
                { "<F17>", function() dap.step_over() end, desc = "[DAP] next" },
                { "<F18>", function() dap.step_into() end, desc = "[DAP] step" },
                { "<leader>b", function() dap.toggle_breakpoint() end, desc = "[DAP] toggle breakpoint" },
            }
        end
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
        config = function(_, opts)
            local dap = require("dap")
            local dapui = require("dapui")
            dapui.setup()
            dap.listeners.before.attach.dapui_config = function() dapui.open() end
            dap.listeners.before.launch.dapui_config = function() dapui.open() end
            dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
            dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
        end,
        keys = {
            { "<leader>td", function() require("dapui").toggle() end, desc = "[DAP] Toggle UI" },
        },
    },
    {
        "mfussenegger/nvim-dap-python",
        lazy = false,
        dependencies = {"mfussenegger/nvim-dap"},
        config = function(_, opts)
            require("dap-python").setup(vim.fn.exepath("python"))
        end,
        keys = {
            { "<leader>tm", function() require("dap-python").test_method() end, desc = "[DAP] Test method" },
        },
    },
}
