-- chrisgrieser/nvim-origami
-- see: <https://github.com/chrisgrieser/nvim-origami>
--
-- 折りたたみ表示の改善

return {
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	opts = {},
	init = function()
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99
	end,
}
