-- neovim/nvim-lspconfig
-- see: <https://github.com/neovim/nvim-lspconfig>
--
-- nvim lspのconfig集

return {
	"neovim/nvim-lspconfig",
	cond = condition,
	event = {
		-- バッファを開くときに読み込み
		"BufReadPre",
		"BufNewFile",
	},
	config = function() end,
}
