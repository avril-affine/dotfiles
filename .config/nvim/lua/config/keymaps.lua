local split_map = {
	["h"] = "v",
	["j"] = "s",
	["k"] = "s",
	["l"] = "v",
}
local function win_move(direction)
	local orig_window = vim.api.nvim_get_current_win()
	vim.cmd.wincmd(direction)
	if orig_window == vim.api.nvim_get_current_win() then
		vim.cmd.wincmd(split_map[direction])
		vim.cmd.wincmd(direction)
	end
end

local silent_nowait = { nowait = true, silent = true }
vim.keymap.set("n", "<C-h>", function() win_move("h") end, silent_nowait ) -- ctrl+h move window up
vim.keymap.set("n", "<C-j>", function() win_move("j") end, silent_nowait ) -- ctrl+j move window down
vim.keymap.set("n", "<C-k>", function() win_move("k") end, silent_nowait ) -- ctrl+k move window left
vim.keymap.set("n", "<C-l>", function() win_move("l") end, silent_nowait ) -- ctrl+l move window right
vim.keymap.set({ "i", "n", "v" }, "˚", ":resize -1<cr>", silent_nowait ) -- alt+k resize window up
vim.keymap.set({ "i", "n", "v" }, "∆", ":resize +1<cr>", silent_nowait ) -- alt+j resize window down
vim.keymap.set({ "i", "n", "v" }, "˙", ":vertical resize -1<cr>", silent_nowait ) -- alt+h resize window left
vim.keymap.set({ "i", "n", "v" }, "¬", ":vertical resize +1<cr>", silent_nowait ) -- alt+l resize window right

vim.keymap.set("n", "<leader>n", ":cnext<cr>", silent_nowait ) -- move to next item in quickfix list
vim.keymap.set("n", "<leader>N", ":cprevious<cr>", silent_nowait ) -- move to previous item in quickfix list

vim.keymap.set("n", "<F16>", ":cclose<cr>") -- test

-- delete to void register
vim.keymap.set({"n", "v"}, "D", '"_d', silent_nowait )
vim.keymap.set({"n", "v"}, "X", '"_x', silent_nowait )
vim.keymap.set({"n", "v"}, "S", '"_s', silent_nowait )
vim.keymap.set({"n", "v"}, "C", '"_c', silent_nowait )

-- center screen after search
vim.keymap.set("n", "n", "nzz", silent_nowait )
vim.keymap.set("n", "N", "Nzz", silent_nowait )

-- copy filepath
vim.keymap.set("n", "<leader>yf", ':let @+=expand("%")<cr>')
