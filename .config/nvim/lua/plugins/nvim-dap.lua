local step_over = function()
    local dap = require("dap")
    dap.step_over()
    vim.cmd("normal! zz")
end

local step_into = function()
    local dap = require("dap")
    dap.step_into()
    vim.cmd("normal! zz")
end

local current_program = nil
local get_rerunnable_file = function()
    if current_program == nil then
        current_program = vim.api.nvim_buf_get_name(0)
    end
    return current_program
end

local reset_program = function()
    current_program = nil
end

return {
    {
        "mfussenegger/nvim-dap",
        config = function(_, opts)
            local dap = require("dap")
            local configs = dap.configurations.python or {}
            dap.configurations.python = configs
            table.insert(configs, {
                type = "python",
                request = "launch",
                name = "Current file with rerun",
                program = get_rerunnable_file,
            })
        end,
        keys = function()
            local dap = require("dap")
            return {
                { "<leader>tc", function() dap.continue() end, desc = "[DAP] continue" },
                { "<leader>tC", reset_program, desc = "[DAP] reset program" },
                { "<leader>tl", function() dap.run_last() end, desc = "[DAP] run last" },
                { "<leader>tD", function() dap.terminate() end, desc = "[DAP] terminate" },
                { "<F17>", step_over, desc = "[DAP] next" },
                { "<leader>tn", step_over, desc = "[DAP] next" },
                { "<F18>", step_into, desc = "[DAP] step" },
                { "<leader>ti", step_into, desc = "[DAP] step" },
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
            dapui.setup({
                layouts = {
                    {
                        elements = {
                            { id = "stacks", size = 0.1 },
                            { id = "breakpoints", size = 0.1 },
                            { id = "scopes", size = 0.1 },
                            { id = "watches", size = 0.7 },
                        },
                        position = "left",
                        size = 0.25,
                    },
                },
            })
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
