-- hedyhli/outline.nvim
-- see: <https://github.com/hedyhli/outline.nvim>
--
-- Outlineの表示に利用

return {
	"hedyhli/outline.nvim",
	lazy = true,
	cmd = { "Outline", "OutlineOpen" },
	keys = {
		{ "<Leader>of", "<cmd>OutlineFollow<CR>", desc = "Outline: Go follow cursor position." },
		{ "<Leader>oo", "<cmd>OutlineOpen<CR>", desc = "⭐︎Outline: Open." },
		{ "<Leader>oq", "<cmd>OutlineClose<CR>", desc = "Outline: Close." },
		{ "<Leader>os", "<cmd>OutlineStatus<CR>", desc = "Outline: Show status." },
		{ "<Leader>or", "<cmd>OutlinesRefresh<CR>", desc = "Outline: Refresh of symbols." },
	},
}
