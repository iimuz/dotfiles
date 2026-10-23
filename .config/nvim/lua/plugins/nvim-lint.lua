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
		-- sh と bash は bashls が内部で shellcheck を動かすので、ここでは指定しない。
		-- zsh は shellcheck が対応しておらず、bash として読ませると zsh 固有の構文を誤検知するので、構文の検査だけにする。
		-- zsh の入っていない環境 (Termux) では、開くたびに実行のエラーが通知されないよう外す。
		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			python = { "ruff" },
			sql = { "sqruff" },
			typescript = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			zsh = vim.fn.executable("zsh") == 1 and { "zsh" } or nil,
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
