-- leapの設定
-- see: <https://codeberg.org/andyg/leap.nvim>
--
-- カーソル移動をラベルで行う。
-- VSCodeから利用するときにeasymotionが利用できないので代わりに利用する。
-- neovim単体であれば他のpluginも利用できるが操作性を変えたくないので同じpluginを利用する。

return {
	url = "https://codeberg.org/andyg/leap.nvim",
	-- 最新版は vim.iter():count() (Neovim 0.13 以降の API) を利用しており、
	-- 0.12 では移動時に実行時エラーとなるため、導入直前の commit に固定する。
	commit = "a5e9dfb25a1cf058811665859db1afc813897ec4",
	-- Do not set lazy loading via your fancy plugin manager
	-- see: <https://github.com/ggandor/leap.nvim?tab=readme-ov-file#installation>
	lazy = false,
	dependencies = {
		"tpope/vim-repeat",
	},
	keys = {
		{ "f", "<Plug>(leap)", mode = { "n", "x", "o" }, desc = "Leap: Forward search." },
		{ "F", "<Plug>(leap-anywhere)", mode = { "n", "x", "o" }, desc = "Leap: Backward search." },
	},
}
