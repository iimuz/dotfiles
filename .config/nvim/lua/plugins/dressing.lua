-- stevearc/dressing.nvim
-- see: <https://github.com/stevearc/dressing.nvim>
--
-- `vim.input`などを見やすく表示するためのプラグイン

-- VSCodeから利用した場合は無効化する
local condition = vim.g.vscode == nil

return {
	"stevearc/dressing.nvim",
	cond = condition,
	event = "VimEnter",
	opts = {},
	config = function()
		require("dressing").setup()
	end,
}
