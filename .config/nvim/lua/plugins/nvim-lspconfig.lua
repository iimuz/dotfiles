-- neovim/nvim-lspconfig
-- see: <https://github.com/neovim/nvim-lspconfig>
--
-- nvim lspのconfig集

return {
	"neovim/nvim-lspconfig",
	event = {
		-- バッファを開くときに読み込み
		"BufReadPre",
		"BufNewFile",
	},
	config = function()
		-- 実行ファイルはmiseで入れており、エージェントからも同じものを使う。
		-- ruff、sqruff、styluaはconformとnvim-lintから呼ぶので、LSPとしては有効にしない。
		vim.lsp.enable({
			"bashls",
			"gopls",
			"lua_ls",
			"marksman",
			"pyright",
			"rust_analyzer",
			"taplo",
			"vtsls",
			"yamlls",
		})
	end,
}
