-- mfussenegger/nvim-lint
-- see: <https://github.com/mfussenegger/nvim-lint>
--
-- Linter
-- 設定の参考例
-- - <https://github.com/josean-dev/dev-environment-files/blob/01d6e00c681c180f302885774add1537030ebb43/.config/nvim/lua/josean/plugins/linting.lua>

local function try_lint()
	local lint = require("lint")
	lint.try_lint()
	-- スペルチェッカーは filetype ではなくリポジトリの設定で選ぶ。
	-- typos はディスク上のファイルを読むので、ファイルでないバッファは対象外にする。
	if vim.bo.buftype == "" then
		lint.try_lint(require("spell-check").linters(0))
	end
end

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
			javascript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			python = { "ruff" },
			sh = { "shellcheck" },
			sql = { "sqruff" },
			typescript = { "eslint_d" },
			typescriptreact = { "eslint_d" },
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
			callback = try_lint,
		})
	end,
	keys = {
		{
			"<Leader>N",
			try_lint,
			desc = "⭐︎Lint: Trigger linting for current file",
		},
	},
}
