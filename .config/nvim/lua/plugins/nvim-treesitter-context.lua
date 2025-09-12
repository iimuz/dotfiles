-- nvim-treesitter/nvim-treesitter-context
-- see: <https://github.com/nvim-treesitter/nvim-treesitter-context>
--
-- Sticky scrollでcontextを考慮して関数の宣言などを残すことができる。

return {
	"nvim-treesitter/nvim-treesitter-context",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	event = { "VimEnter" },
	config = function()
		require("treesitter-context").setup()
	end,
}
