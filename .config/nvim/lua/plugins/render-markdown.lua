-- MeanderingProgrammer/render-markdown.nvim
-- see: <https://github.com/MeanderingProgrammer/render-markdown.nvim
--
-- Markdown preview

return {
	"MeanderingProgrammer/render-markdown.nvim",
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
	keys = {
		{ "<Leader>Re", "<cmd>RenderMarkdown enable<CR>", desc = "⭐︎RenderMarkdown: Enable." },
		{ "<Leader>Rd", "<cmd>RenderMarkdown disable<CR>", desc = "⭐︎RenderMarkdown: Disable." },
	},
}
