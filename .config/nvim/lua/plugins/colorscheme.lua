-- Colorscheme
--
--Colorschemeは、どれか一つで良いので全てここにまとめる

return {
	-- cyberdream
	-- see: <https://github.com/scottmckendry/cyberdream.nvim>
	{
		"scottmckendry/cyberdream.nvim",
		lazy = false,
		enabled = true,
		priority = 1000,
		config = function()
			require("cyberdream").setup({})
			vim.cmd([[ colorscheme cyberdream ]])
		end,
	},
}
