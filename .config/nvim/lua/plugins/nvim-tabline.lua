-- crispgm/nvim-tabline
-- see: <https://github.com/crispgm/nvim-tabline?tab=readme-ov-file#Differences>
--
-- Tabの表示改善。

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
	"crispgm/nvim-tabline",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cond = condition,
	event = { "VimEnter" },
	opts = {
		show_modify = false,
		show_icon = true,
	},
}
