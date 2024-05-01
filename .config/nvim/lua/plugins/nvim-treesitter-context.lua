-- nvim-treesitter/nvim-treesitter-context
-- see: <https://github.com/nvim-treesitter/nvim-treesitter-context>
--
-- Sticky scrollでcontextを考慮して関数の宣言などを残すことができる。

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
	"nvim-treesitter/nvim-treesitter-context",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	cond = condition,
	event = { "VimEnter" },
	config = function()
		require("treesitter-context").setup()
	end,
}
