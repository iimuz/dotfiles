-- linrongbin16/gitlinker.nvim
-- see: <https://github.com/linrongbin16/gitlinker.nvim>
--
-- コードからgithubリポジトリのソースコードのurl取得

return {
	"linrongbin16/gitlinker.nvim",
	cmd = "GitLink",
	opts = {},
	keys = {
		{
			"<leader>ub",
			function()
				require("gitlinker").link({ router_type = "blame" })
			end,
			mode = { "n", "v" },
			desc = "GitLinker: Yank git blame link.",
		},
		{
			"<leader>uB",
			function()
				require("gitlinker").link({
					router_type = "blame",
					action = require("gitlinker.actions").system,
				})
			end,
			mode = { "n", "v" },
			desc = "GitLinker: Open git blame link.",
		},
		{
			"<leader>uc",
			function()
				require("gitlinker").link({ router_type = "current_branch" })
			end,
			mode = { "n", "v" },
			desc = "GitLinker: Yank current branch link.",
		},
		{
			"<leader>uC",
			function()
				require("gitlinker").link({
					router_type = "current_branch",
					action = require("gitlinker.actions").system,
				})
			end,
			mode = { "n", "v" },
			desc = "GitLinker: Open current branch link.",
		},
		{
			"<leader>ul",
			function()
				require("gitlinker").link()
			end,
			mode = { "n", "v" },
			desc = "GitLinker: Yank git permlink.",
		},
		{
			"<leader>uL",
			function()
				require("gitlinker").link({ action = require("gitlinker.actions").system })
			end,
			mode = { "n", "v" },
			desc = "GitLinker: Open git permlink.",
		},
	},
}
