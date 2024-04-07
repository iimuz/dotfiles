-- nvim-lualine/lualine.nvim
-- see: <https://github.com/nvim-lualine/lualine.nvim>
--
-- status lineの変更

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	cond = condition,
	event = { "VimEnter" },
	config = function()
		require("lualine").setup({})
	end,
}
