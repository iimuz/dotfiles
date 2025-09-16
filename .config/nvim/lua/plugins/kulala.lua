-- mistweaverco/kulala.nvim
-- see: <https://github.com/mistweaverco/kulala.nvim>
--
-- http client

return {
	"mistweaverco/kulala.nvim",
	ft = { "http", "rest" },
	opts = {
		global_keymaps = false,
		kulala_keymaps_prefix = "",
	},
	keys = {
		{
			"<leader>ka",
			function()
				require("kulala").run_all()
			end,
			desc = "Kulala: Send all requests.",
		},
		{
			"<leader>kb",
			function()
				require("kulala").scratchpad()
			end,
			desc = "Kulala: Open scratchpad.",
		},
		{
			"<leader>kc",
			function()
				require("kulala").copy()
			end,
			mode = { "n", "v" },
			desc = "Kulala: Copy as curl.",
		},
		{
			"<leader>kC",
			function()
				require("kulala").from_curl()
			end,
			mode = { "n", "v" },
			desc = "Kulala: Paste from curl.",
		},
		{
			"<leader>ke",
			function()
				require("kulala").set_selected_env()
			end,
			mode = { "n" },
			desc = "Kulala: Select env.",
		},
		{
			"<leader>kf",
			function()
				require("kulala").search()
			end,
			mode = { "n" },
			desc = "Kulala: Find request.",
		},
		{
			"<leader>ki",
			function()
				require("kulala").inspect()
			end,
			mode = { "n" },
			desc = "Kulala: Inspect curl request.",
		},
		{
			"<leader>kn",
			function()
				require("kulala").jump_next()
			end,
			mode = { "n" },
			desc = "Kulala: Jump to next request.",
		},
		{
			"<leader>kp",
			function()
				require("kulala").jump_prev()
			end,
			mode = { "n" },
			desc = "Kulala: Jump to previous request.",
		},
		{
			"<leader>kr",
			function()
				require("kulala").replay()
			end,
			mode = { "n" },
			desc = "Kulala: Replay the last request",
		},
		{
			"<leader>ks",
			function()
				require("kulala").run()
			end,
			mode = { "n", "v" },
			desc = "Kulala: Send request",
		},
		{
			"<leader>kx",
			function()
				require("kulala").scripts_clear_global()
			end,
			mode = { "n" },
			desc = "Kulala: Clear globals",
		},
		{
			"<leader>kX",
			function()
				require("kulala").clear_cached_files()
			end,
			mode = { "n" },
			desc = "Kulala: Clear cached files",
		},
	},
}
