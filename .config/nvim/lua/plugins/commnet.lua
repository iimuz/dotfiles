-- numToStr/Comment.nvim
-- see: <https://github.com/numToStr/Comment.nvim>
--
-- コードのコメント操作

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
	"numToStr/Comment.nvim",
	cond = condition,
	event = { "VimEnter" },
	config = function()
		require("Comment").setup()
	end,
}
