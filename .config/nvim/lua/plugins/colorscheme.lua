-- Colorscheme
--
--Colorschemeは、どれか一つで良いので全てここにまとめる

return {
	-- catppuccin
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		enabled = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "frappe",
				integrations = {
					diffview = true,
				},
			})

			vim.cmd([[ colorscheme catppuccin ]])
		end,
	},
	-- iceverg
	-- see: <https://github.com/cocopon/iceberg.vim>
	{
		"cocopon/iceberg.vim",
		lazy = false,
		enabled = false,
		config = function()
			vim.opt.termguicolors = true
			vim.opt.background = "dark"
			vim.cmd([[ colorscheme iceberg ]])
		end,
	},
	-- nightfox
	-- see: <https://github.com/EdenEast/nightfox.nvim>
	{
		"EdenEast/nightfox.nvim",
		lazy = false,
		enabled = false,
		config = function()
			vim.opt.termguicolors = true
			vim.opt.background = "dark"
			vim.cmd([[ colorscheme nightfox ]])
		end,
	},
	{
		"projekt0n/github-nvim-theme",
		lazy = false,
		enabled = false,
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			require("github-theme").setup({})
			vim.cmd([[ colorscheme github_dark ]])
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		enabled = true,
		priority = 1000,
		config = function()
			vim.cmd([[ colorscheme tokyonight-night ]])
		end,
	},
}
