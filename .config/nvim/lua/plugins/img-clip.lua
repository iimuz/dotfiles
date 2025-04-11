-- HakonHarnes/img-clip.nvim
-- see: <https://github.com/HakonHarnes/img-clip.nvim>
--
-- Embed images into any markup languages, like Latex, zmarkdown or Typst
--
-- 2025-04-11 明示的に導入しているわけではないが依存関係で導入されている。
-- また、mac環境にて Content is not an imageというエラーが発生するため対応を追加。

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
	"HakonHarnes/img-clip.nvim",
	cond = condition,
	event = "VeryLazy",
	opts = {
		-- add options here
		-- or leave it empty to use the default settings
	},
	keys = {},
}
