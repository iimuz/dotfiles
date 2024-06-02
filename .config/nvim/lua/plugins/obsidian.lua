-- epwalsh/obsidian.nvim
--
-- obsidianの機能の一部をnvimでも実現する。
--
-- 2024-05-30
-- obsidianを編集するためにはneovimを利用しているが、viewerとして導入した。
-- ただ、補完機能が重かったり動作として不要なものも多かったので無効化。

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	cond = condition,
	enabled = false, -- 思ったより使いにくかったので無効化
	dependencies = {
		"hrsh7th/nvim-cmp",
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		workspaces = {
			{
				name = "scratchpad",
				path = "~/src/github.com/iimuz/scratchpad",
			},
		},
		preferred_link_style = "markdown",
		disable_frontmatter = false,
		-- uiをリッチにする必要性を感じないので無効化
		ui = {
			enable = false,
		},
	},
}
