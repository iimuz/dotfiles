-- OXY2DEV/markview.nvim
-- see: <https://github.com/OXY2DEV/markview.nvim>
--
-- Markdown preview
--
-- 2025-03-17: avanteの利用するrender-markdownと干渉するので、こちらをfalseにする

return {
	"OXY2DEV/markview.nvim",
	lazy = false, -- it is already lazy-loaded
	enabled = false,
}
