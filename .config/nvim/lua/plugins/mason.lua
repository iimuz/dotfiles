-- LSP設定
-- 複数のプラグインが依存するためLSP関連をまとめて記述

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

-- Neovim builtin LSPを利用する前提
return {
	-- LSP manager - mason
	{
		"williamboman/mason.nvim",
		cond = condition,
		cmd = { "Mason", "MasonUpdate" },
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			require("mason").setup()
		end,
	},
	-- mason-lspconfigの設定
	-- see: <https://github.com/williamboman/mason-lspconfig.nvim>
	{
		"williamboman/mason-lspconfig.nvim",
		cond = condition,
		event = { "VimEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- capabilityを設定
			"WhoIsSethDaniel/mason-tool-installer.nvim", -- masonでensure_installedできないツールの対応
			-- "williamboman/mason.nvim",
		},
		config = function()
			require("mason-lspconfig").setup({
				automatic_enable = true,
				-- よく使うLSPはインストールしておく。
				-- formatter, linterについては下記のpluginを利用する。
				-- ただし、インストールしておくpluginをここで指定して、どのファイルタイプに対して適用するかは、plugin側の設定で行う。
				-- - formatter: stevearc/conform.nvim
				-- - linter: mfussenegger/nvim-lint
				ensure_installed = {
					"gopls", -- Go lang LSP
					"lua_ls", -- Lua LSP
					"marksman", -- Markdown LSP
					"pyright", -- Python LSP
					"rust_analyzer", -- Rust LSP
				},
			})

			require("mason-tool-installer").setup({
				ensure_installed = {
					"cspell", -- spell checker(linter)
					"dprint", -- Markdown, json, toml formatter
					"prettier", -- formatter
					"ruff", -- Python linter, formatter
					-- "ruff-lsp", -- Python linter, formatter
					"stylua", -- lua formatter
				},
			})

			-- Setup lspconfig to nvim-cmp
			-- v0.11のLSP変更で不要になった?
			-- local capabilities = require("cmp_nvim_lsp").default_capabilities()
			-- require("mason-lspconfig").setup_handlers({
			-- 	function(server_name)
			-- 		local server = require("lspconfig")[server_name]
			-- 		if server ~= nil then
			-- 			server.setup({
			-- 				capabilities = capabilities,
			-- 			})
			-- 		end
			-- 	end,
			-- })
			vim.lsp.enable(require("mason-lspconfig").get_installed_servers())
		end,
	},
}
