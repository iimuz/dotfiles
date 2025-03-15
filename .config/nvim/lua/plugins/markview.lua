-- OXY2DEV/markview.nvim
-- see: <https://github.com/OXY2DEV/markview.nvim>
--
-- Markdown preview

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
	"OXY2DEV/markview.nvim",
	lazy = false, -- it is already lazy-loaded
	cond = condition,
}
