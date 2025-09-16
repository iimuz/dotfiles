-- crispgm/nvim-tabline
-- see: <https://github.com/crispgm/nvim-tabline?tab=readme-ov-file#Differences>
--
-- Tabの表示改善。

return {
	"crispgm/nvim-tabline",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = { "VimEnter" },
	opts = {
		show_modify = false,
		show_icon = true,
	},
}
