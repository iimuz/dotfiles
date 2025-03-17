-- MeanderingProgrammer/render-markdown.nvim
-- see: <https://github.com/MeanderingProgrammer/render-markdown.nvim
--
-- Markdown preview

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
	"MeanderingProgrammer/render-markdown.nvim",
	cond = condition,
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	opts = {
		-- 挿入モードにおいてもカーソル行のみレンダリングしないように設定
		render_modes = true,
		-- 見出し行でアイコンを利用せずパディングしない
		heading = {
			width = "block",
			left_pad = 0,
			right_pad = 4,
			icons = {},
		},
	},
	ft = { "markdown" },
}
