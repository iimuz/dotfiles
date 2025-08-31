-- gitsigns.nvimの設定
-- see: <https://github.com/lewis6991/gitsigns.nvim>
--
-- gitの変更点を可視化

-- vscodeから呼び出されているときは利用しない
local condition = vim.g.vscode == nil

return {
	"lewis6991/gitsigns.nvim",
	cond = condition,
	event = { "BufRead", "BufNewFile" },
	opts = {
		word_diff = false,
	},
}
