-- hedyhli/outline.nvim
-- see: <https://github.com/hedyhli/outline.nvim>
--
-- Outlineの表示に利用

return {
	"hedyhli/outline.nvim",
	lazy = true,
	cmd = { "Outline", "OutlineOpen" },
	opts = {},
	keys = {
		{ "<Leader>of", "<cmd>OutlineFollow<CR>", desc = "Outline: Go follow cursor position." },
		{ "<Leader>oo", "<cmd>OutlineOpen<CR>", desc = "⭐︎Outline: Open." },
		{ "<Leader>os", "<cmd>OutlineStatus<CR>", desc = "Outline: Show status." },
		{ "<Leader>or", "<cmd>OutlinesRefresh<CR>", desc = "Outline: Refresh of symbols." },
		{ "<Leader>ox", "<cmd>OutlineClose<CR>", desc = "Outline: Close." },
	},
}
