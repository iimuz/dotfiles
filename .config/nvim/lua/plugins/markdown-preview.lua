-- markdown-preview.nvim
-- see: <https://github.com/iamcco/markdown-preview.nvim>
--
-- Preview markdown file.

local set = vim.keymap.set
set("n", "<Plug>(MarkdownPreview.Open)", "<cmd>MarkdownPreview<CR>", { desc = "⭐︎MarkdownPreview: Show." })

return {
	"iamcco/markdown-preview.nvim",
	lazy = true,
	cmd = {
		"MarkdownPreviewToggle",
		"MarkdownPreview",
		"MarkdownPreviewStop",
	},
	ft = { "markdown" },
	build = function()
		vim.fn["mkdp#util#install"]()
	end,
	config = function()
		vim.g.mkdp_preview_options = {
			disable_sync_scroll = 1,
		}

		set("n", "<Plug>(MarkdownPreview.Stop)", "<cmd>MarkdownPreviewStop<CR>", { desc = "MarkdownPreview: Stop." })
		set(
			"n",
			"<Plug>(MarkdownPreview.Toggle)",
			"<cmd>MarkdownPreviewToggle<CR>",
			{ desc = "MarkdownPreview: Toggle." }
		)
	end,
}
