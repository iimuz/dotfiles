-- markdown-preview.nvim
-- see: <https://github.com/iamcco/markdown-preview.nvim>
--
-- Preview markdown file.
--
-- - 2024-07-04: vscodeとの併用で利用しなくなったので無効化

return {
	"iamcco/markdown-preview.nvim",
	lazy = true,
	enabled = false,
	cmd = { "MarkdownPreview" },
	ft = { "markdown" },
	build = function()
		vim.fn["mkdp#util#install"]()
	end,
	config = function()
		vim.g.mkdp_preview_options = {
			disable_sync_scroll = 1, -- エディタのスクロールにプレビューを一致させない
		}
	end,
}
