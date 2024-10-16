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

vim.g.mapleader = ","

local set_keymap = vim.keymap.set

set_keymap("n", "<leader>f", function() require("telescope.builtin").live_grep() end)
set_keymap("n", "<C-p>", function() require("telescope.builtin").find_files() end)

set_keymap("n", "<C-h>", function() win_move("h") end, { nowait = true, silent = true }) -- ctrl+h move window up
set_keymap("n", "<C-j>", function() win_move("j") end, { nowait = true, silent = true }) -- ctrl+j move window down
set_keymap("n", "<C-k>", function() win_move("k") end, { nowait = true, silent = true }) -- ctrl+k move window left
set_keymap("n", "<C-l>", function() win_move("l") end, { nowait = true, silent = true }) -- ctrl+l move window right
set_keymap({ "i", "n", "v" }, "˚", ":resize -1<cr>", { nowait = true, silent = true }) -- alt+k resize window up
set_keymap({ "i", "n", "v" }, "∆", ":resize +1<cr>", { nowait = true, silent = true }) -- alt+j resize window down
set_keymap({ "i", "n", "v" }, "˙", ":vertical resize -1<cr>", { nowait = true, silent = true }) -- alt+h resize window left
set_keymap({ "i", "n", "v" }, "¬", ":vertical resize +1<cr>", { nowait = true, silent = true }) -- alt+l resize window right

set_keymap("n", "<leader>n", ":cnext<cr>", { nowait = true, silent = true }) -- move to next item in quickfix list
set_keymap("n", "<leader>N", ":cprevious<cr>", { nowait = true, silent = true }) -- move to previous item in quickfix list

set_keymap("n", "<F16>", ":cclose<cr>")

-- delete to void register
set_keymap({"n", "v"}, "D", '"_d', { nowait = true, silent = true })
set_keymap({"n", "v"}, "X", '"_x', { nowait = true, silent = true })
set_keymap({"n", "v"}, "S", '"_s', { nowait = true, silent = true })
set_keymap({"n", "v"}, "C", '"_c', { nowait = true, silent = true })
