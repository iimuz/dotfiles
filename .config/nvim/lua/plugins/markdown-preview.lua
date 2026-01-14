-- markdown-preview.nvim
-- see: <https://github.com/iamcco/markdown-preview.nvim>
--
-- Preview markdown file.

return {
	"iamcco/markdown-preview.nvim",
	lazy = true,
	enabled = true,
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown" },
	build = "cd app && npm install --ignore-scripts",
	config = function()
		vim.g.mkdp_filetypes = { "markdown" }
		vim.g.mkdp_preview_options = {
			disable_sync_scroll = 1, -- エディタのスクロールにプレビューを一致させない
		}
	end,
	keys = {
		{ "<Leader>ms", "<cmd>MarkdownPreview<CR>", desc = "MarkdownPreview: Start markdown preview." },
		{ "<Leader>mq", "<cmd>MarkdownPreviewStop<CR>", desc = "MarkdownPreview: Stop markdown preview." },
	},
}
