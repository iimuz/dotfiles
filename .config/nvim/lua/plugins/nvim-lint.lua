-- mfussenegger/nvim-lint
-- see: <https://github.com/mfussenegger/nvim-lint>
--
-- Linter
-- 設定の参考例
-- - <https://github.com/josean-dev/dev-environment-files/blob/01d6e00c681c180f302885774add1537030ebb43/.config/nvim/lua/josean/plugins/linting.lua>

return {
	"mfussenegger/nvim-lint",
	event = {
		-- バッファを読み込んだときに有効化
		"BufReadPre",
		"BufNewFile",
	}, -- to disable, comment this out
	config = function()
		local lint = require("lint")

		-- ファイルタイプごとのlinterの設定
		lint.linters_by_ft = {
			bash = { "shellcheck" },
			css = { "cspell" },
			html = { "cspell" },
			javascript = { "eslint_d", "cspell" },
			javascriptreact = { "eslint_d", "cspell" },
			json = { "cspell" },
			lua = { "cspell" },
			markdown = { "cspell" },
			python = { "ruff", "cspell" },
			sh = { "shellcheck" },
			sql = { "sqruff" },
			typescript = { "eslint_d", "cspell" },
			typescriptreact = { "eslint_d", "cspell" },
			yaml = { "cspell" },
			zsh = { "shellcheck" },
		}

		-- shellcheckの設定カスタマイズ
		lint.linters.shellcheck.args = {
			"--format=json",
			"--shell=bash", -- デフォルトシェルをbashに指定
			-- "--exclude=SC1091,SC2034", -- 特定のエラーを除外
			"-",
		}

		-- eslint_dの設定カスタマイズ
		-- monorepoでrootのeslint.config.jsが各プロジェクトを除外している場合の警告を抑制
		lint.linters.eslint_d.args = {
			"--no-warn-ignored",
			"--format",
			"json",
			"--stdin",
			"--stdin-filename",
			function()
				return vim.api.nvim_buf_get_name(0)
			end,
		}

		-- バッファの書き込み時にlintを実行
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({
			"BufEnter",
			"BufWritePost",
			"InsertLeave",
		}, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})
	end,
	keys = {
		{
			"<Leader>N",
			function()
				require("lint").try_lint()
			end,
			desc = "⭐︎Lint: Trigger linting for current file",
		},
	},
}
