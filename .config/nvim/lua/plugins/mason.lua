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
		keys = {
			{ "<Leader>Ml", "<cmd>MasonLog<CR>", desc = "Mason: Show log." },
			{ "<Leader>Mo", "<cmd>Mason<CR>", desc = "⭐︎Mason: Show Mason UI." },
			{ "<Leader>Mt", "<cmd>MasonToolsUpdate<CR>", desc = "MasonTools: update." },
			{ "<Leader>Mu", "<cmd>MasonUpdate<CR>", desc = "Mason: update." },
		},
	},
	-- mason-lspconfigの設定
	-- see: <https://github.com/williamboman/mason-lspconfig.nvim>
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "VimEnter" },
		dependencies = {
			"neovim/nvim-lspconfig", -- 不足していた必須依存
			"williamboman/mason.nvim",
		},
		config = function()
			require("mason-lspconfig").setup({})
		end,
	},
	-- masonでツールを自動インストール
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			-- よく使う LSP, Tool はインストールしておく。
			-- formatter, linter については下記の plugin を利用する。
			-- ただし、インストールしておく plugin をここで指定して、どのファイルタイプに対して適用するかは、 plugin 側の設定で行う。
			-- - formatter: stevearc/conform.nvim
			-- - linter: mfussenegger/nvim-lint
			require("mason-tool-installer").setup({
				ensure_installed = {
					"bashls", -- Bash LSP
					"copilot-language-server", -- GitHub Copilot LSP
					"cspell", -- CSpell
					"cspell-lsp", -- CSpell
					"eslint_d", -- Javascript and Typescript linter
					"gopls", -- Go lang LSP
					"kulala-fmt", -- HTTP formatter and linter
					"lua_ls", -- Lua LSP
					"marksman", -- Markdown LSP
					"prettier", -- Formatter for various file types
					"pyright", -- Python LSP
					"ruff", -- Python linter and formatter
					"rust_analyzer", -- Rust LSP
					"shfmt", -- Bash formatter
					"shellcheck", -- Bash linter
					"solhint", -- Solidity linter
					"solidity_ls_nomicfoundation", -- Solidity LSP
					"sqruff", -- SQL linter and formatter
					"stylua", -- Lua linter and formatter
					"taplo", -- TOML LSP
					-- "tsp-server ", -- Typespec LSP(手動でのみインストールできた)
					"vtsls", -- Javascript and Typescript LSP
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
