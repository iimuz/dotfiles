-- pwntester/octo.nvim
-- see: <https://github.com/pwntester/octo.nvim>
--
-- GitHubのPRのレビュー

return {
	"pwntester/octo.nvim",
	cmd = { "Octo" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"folke/snacks.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "<Leader>Op", "<cmd>Octo pr list<CR>", desc = "⭐︎Octo: List PRs." },
		{ "<Leader>Or", "<cmd>Octo review<CR>", desc = "⭐︎Octo: Start or resume review." },
		{ "<Leader>Oc", "<cmd>Octo review comments<CR>", desc = "Octo: View pending review comments." },
		{ "<Leader>Os", "<cmd>Octo review submit<CR>", desc = "⭐︎Octo: Submit review." },
		{ "<Leader>Ox", "<cmd>Octo review discard<CR>", desc = "Octo: Discard pending review." },
	},
	opts = {
		picker = "snacks",
		use_local_fs = true,
	},
}
