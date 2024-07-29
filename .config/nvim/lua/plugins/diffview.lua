-- diffview.nvim
-- see: <https://github.com/sindrets/diffview.nvim>
--
-- gitの差分表示
--
-- - 2024-07-04: vscodeとの併用のため、利用しなくなったので無効化

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
	"sindrets/diffview.nvim",
	cond = condition,
	enabled = false,
	cmd = { "DiffviewOpen", "DiffviewFileHistory" },
	config = function()
		require("diffview").setup({})
	end,
}
