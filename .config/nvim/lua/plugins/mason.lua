-- LSP設定
-- 複数のプラグインが依存するためLSP関連をまとめて記述

-- Neovim builtin LSPを利用する前提
return {
	-- LSP manager - mason
	{
		"williamboman/mason.nvim",
		cmd = { "Mason", "MasonUpdate" },
		-- 循環依存を削除（同じファイル内で順序保証）
		config = function()
			require("mason").setup()
		end,
	},
	-- mason-lspconfigの設定
	-- see: <https://github.com/williamboman/mason-lspconfig.nvim>
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "VimEnter" },
		dependencies = {
			"neovim/nvim-lspconfig", -- 不足していた必須依存
			"hrsh7th/cmp-nvim-lsp", -- capabilityを設定
			"williamboman/mason.nvim",
		},
		config = function()
			require("mason-lspconfig").setup({
				-- よく使うLSPはインストールしておく。
				-- formatter, linterについては下記のpluginを利用する。
				-- ただし、インストールしておくpluginをここで指定して、どのファイルタイプに対して適用するかは、plugin側の設定で行う。
				-- - formatter: stevearc/conform.nvim
				-- - linter: mfussenegger/nvim-lint
				ensure_installed = {
					"bashls", -- Bash LSP
					"gopls", -- Go lang LSP
					"lua_ls", -- Lua LSP
					"marksman", -- Markdown LSP
					"solidity_ls_nomicfoundation", -- Solidity LSP
					"pyright", -- Python LSP
					"rust_analyzer", -- Rust LSP
					"vtsls", -- Javascript and Typescript LSP
				},
			})
		end,
	},
	-- masonでツールを自動インストール
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"cspell", -- CSpell
					"cspell-lsp", -- CSpell
					"eslint_d", -- Javascript and Typescript linter
					"ruff", -- Python linter and formatter
					"shfmt", -- Bash formatter
					"shellcheck", -- Bash linter
					"solhint", -- Solidity linter
					"sqruff", -- SQL linter and formatter
					"stylua", -- Lua linter and formatter
					-- "tsp-server ", -- Typespec LSP(手動でのみインストールできた)
				},
				auto_update = true,
				run_on_start = true,
				start_delay = 3000,
				integrations = {
					["mason-lspconfig"] = true,
					["mason-null-ls"] = false,
					["mason-nvim-dap"] = false,
				},
			})
		end,
	},
}
