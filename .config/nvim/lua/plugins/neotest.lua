-- nvim-neotest/neotest
-- see: <https://github.com/nvim-neotest/neotest>
--
-- neovimでtestを扱う

return {
	"nvim-neotest/neotest",
	enabled = true,
	cmd = { "Neotest" },
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		{ "fredrikaverpil/neotest-golang", version = "*" },
	},
	opts = function()
		return {
			adapters = {
				require("neotest-golang")({}),
			},
		}
	end,
}
