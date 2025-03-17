-- OXY2DEV/markview.nvim
-- see: <https://github.com/OXY2DEV/markview.nvim>
--
-- Markdown preview
--
-- 2025-03-17: avanteの利用するrender-markdownと干渉するので、こちらをfalseにする

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
	"OXY2DEV/markview.nvim",
	lazy = false, -- it is already lazy-loaded
	cond = condition,
	enabled = false,
}
