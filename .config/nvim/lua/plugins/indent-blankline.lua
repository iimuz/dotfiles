-- lukas-reineke/indent-blankline.nvim
-- see: <https://github.com/lukas-reineke/indent-blankline.nvim>
--
-- インデントの可視化

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
	"lukas-reineke/indent-blankline.nvim",
	cond = condition,
	event = { "VimEnter" },
	main = "ibl",
	opts = {},
}
