-- pwntester/octo.nvim
-- see: <https://github.com/pwntester/octo.nvim>
--
-- GitHubの操作を行う
--
-- - 2024-07-04: vscodeと併用しており利用しないので無効化
-- - 2025-09-13: vscodeの使い方を変えたので有効化

local set = vim.keymap.set
set("n", "<Plug>octo.load", "<cmd>Octo<CR>", { desc = "⭐︎Octo: Load octo plugin." })

return {
	"pwntester/octo.nvim",
	cmd = { "Octo" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("octo").setup({
			mappings_disable_default = false, -- defaultのショートカットキーは無効化
		})
	end,
	keys = {
		-- Comment
		{ "<Leader>Oca", "<cmd>Octo comment add<CR>", mode = { "n", "v" }, desc = "⭐︎Octo: Add a new comment." },
		{ "<Leader>Ocd", "<cmd>Octo comment delete<CR>", desc = "⭐︎Octo: Delete a comment." },
		-- rEpository
		{ "<Leader>Oeb", "<cmd>Octo repo browser<CR>", desc = "Octo: Open current repo in the browser." },
		{
			"<Leader>Oeu",
			"<cmd>Octo repo url<CR>",
			desc = "Octo: Copies the URL of the current repository to the system clipboard.",
		},
		-- Gist
		{ "<Leader>Og", "<cmd>Octo gist list<CR>", desc = "Octo: List user gists." },
		-- Issue
		{ "<Leader>Oil", "<cmd>Octo issue list<CR>", desc = "⭐︎Octo: List issues." },
		{ "<Leader>Oio", "<cmd>Octo issue rowser<CR>", desc = "Octo: Open current issue in the browser." },
		{ "<Leader>Oir", "<cmd>Octo issue reload<CR>", desc = "Octo: Reload issue." },
		{
			"<Leader>Oiu",
			"<cmd>Octo issue url<CR>",
			desc = "Octo: Copies the URL of the current issue to the system clipboard.",
		},
		{ "<Leader>Oi/", "<cmd>Octo issue search<CR>", desc = "Octo: Live issue search." },
		-- Pr
		{ "<Leader>Opc", "<cmd>Octo pr checkout<CR>", desc = "⭐︎Octo: Checkout PR." },
		{ "<Leader>Opd", "<cmd>Octo pr diff<CR>", desc = "Octo: Show PR diff." },
		{ "<Leader>Oph", "<cmd>Octo pr checks<CR>", desc = "Octo: Show the status of all checks run on the PR." },
		{ "<Leader>Opl", "<cmd>Octo pr list<CR>", desc = "⭐︎Octo: List PRs." },
		{ "<Leader>Opm", "<cmd>Octo pr commits<CR>", desc = "Octo: List all PR commits." },
		{ "<Leader>Opn", "<cmd>Octo pr reload<CR>", desc = "Octo: Reload PR." },
		{ "<Leader>Opo", "<cmd>Octo pr browser<CR>", desc = "Octo: Open current PR in the browser." },
		-- review
		{ "<Leader>Orb", "<cmd>Octo review submit<CR>", desc = "⭐︎Octo: Submit the review." },
		{ "<Leader>Orc", "<cmd>Octo review comments<CR>", desc = "⭐︎Octo: View pending review comments." },
		{
			"<Leader>Ord",
			"<cmd>Octo review discard<CR>",
			desc = "Octo: Deletes a pending review for current PR if any.",
		},
		{
			"<Leader>Orq",
			"<cmd>Octo review close<CR>",
			desc = "⭐︎Octo: Close the review window and return to the PR.",
		},
		{
			"<Leader>Orr",
			"<cmd>Octo review resume<CR>",
			desc = "⭐︎Octo: Edit a pending review for current PR.",
		},
		{ "<Leader>Ors", "<cmd>Octo review start<CR>", desc = "⭐︎Octo: Start a new review." },
		{
			"<Leader>Opu",
			"<cmd>Octo pr url<CR>",
			desc = "Octo: Copies the URL of the current PR to the system clipboard.",
		},
		{ "<Leader>Op/", "<cmd>Octo pr search<CR>", desc = "Octo: Live PR search." },
		-- thread
		{ "<Leader>Otr", "<cmd>Octo thread resolve<CR>", desc = "⭐︎Octo: Resolve a review thread." },
		{ "<Leader>Oto", "<cmd>Octo thread unresolve<CR>", desc = "Octo: Unresolve a review thread." },
	},
}
