local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
local lazyvim_path = vim.fn.stdpath("data") .. "/lazy/LazyVim"
if not vim.loop.fs_stat(lazyvim_path) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/LazyVim/LazyVim.git",
		"--branch=main",
		lazyvim_path,
	})
end

vim.opt.rtp:prepend(vim.env.LAZY or lazypath)
require("lazy").setup("plugins", {
    install = { colorscheme = { "catpuccin" } },
	defaults = {
		lazy = false,
		version = false, -- always use the latest git commit
	},
    ui = {
        icons = {
            cmd = " ",
            config = "",
            event = "",
            ft = " ",
            init = " ",
            import = " ",
            keys = " ",
            lazy = "󰒲 ",
            loaded = "●",
            not_loaded = "○",
            plugin = " ",
            runtime = " ",
            source = " ",
            start = "",
            task = "✔ ",
            list = {
                "●",
                "➜",
                "★",
                "‒",
            },
        },
    },
	performance = {
        cache = {
            enable = true,
        },
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
