-- leapの設定
-- see: <https://codeberg.org/andyg/leap.nvim>
--
-- カーソル移動をラベルで行う。

return {
	url = "https://codeberg.org/andyg/leap.nvim",
	-- Do not set lazy loading via your fancy plugin manager
	-- see: <https://github.com/ggandor/leap.nvim?tab=readme-ov-file#installation>
	lazy = false,
	dependencies = {
		"tpope/vim-repeat",
	},
	keys = {
		{ "f", "<Plug>(leap)", mode = { "n", "x", "o" }, desc = "Leap: Forward search." },
		{ "F", "<Plug>(leap-anywhere)", mode = { "n", "x", "o" }, desc = "Leap: Search in all windows." },
	},
}
