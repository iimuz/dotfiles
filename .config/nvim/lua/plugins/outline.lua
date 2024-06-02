-- hedyhli/outline.nvim
-- see: <https://github.com/hedyhli/outline.nvim>
--
-- Outlineの表示に利用

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
	"hedyhli/outline.nvim",
	lazy = true,
	cond = condition,
	cmd = { "Outline", "OutlineOpen" },
	opts = {},
}
