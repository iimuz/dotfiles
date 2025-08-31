-- Typescript, Javascriptの設定

return {
	-- LSP
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"vtsls",
			},
		},
	},
	-- linter
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = {
			ensure_installed = {
				"eslint_d",
			},
		},
	},
	-- formatter
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
			},
		},
	},
}
