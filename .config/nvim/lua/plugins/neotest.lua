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
	keys = {
		{
			"<Leader>el",
			function()
				require("neotest").run.run_last()
			end,
			desc = "Neotest: Run test last.",
		},
		{
			"<Leader>en",
			function()
				require("neotest").run.run()
			end,
			desc = "Neotest: Run test nearest.",
		},
		{
			"<Leader>eO",
			function()
				require("neotest").output_panel.toggle()
			end,
			desc = "Neotest: Toggl test output panel.",
		},
		{
			"<Leader>eo",
			function()
				require("neotest").output.open({ enter = true, auto_close = true })
			end,
			desc = "Neotest: Test output.",
		},
		{
			"<Leader>es",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Neotest: Toggle test summary.",
		},
		{
			"<Leader>et",
			function()
				require("neotest").run.stop()
			end,
			desc = "Neotest: Test terminate.",
		},
	},
}
