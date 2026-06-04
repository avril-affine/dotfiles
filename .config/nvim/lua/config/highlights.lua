-- nvim-dap sign definitions; highlight groups are owned by the active colorscheme.
vim.fn.sign_define("DapBreakpoint", { text="🛑", texthl="DapBreakpoint" })
vim.fn.sign_define("DapStopped", {text="→", texthl="DapStoppedText", linehl="DapStoppedLine", numhl="DapStoppedText"})
