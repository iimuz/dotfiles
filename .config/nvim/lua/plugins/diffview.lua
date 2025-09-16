-- diffview.nvim
-- see: <https://github.com/sindrets/diffview.nvim>
--
-- gitの差分表示

return {
	"sindrets/diffview.nvim",
	enabled = true,
	cmd = { "DiffviewOpen", "DiffviewFileHistory" },
	keys = {
		{
			"<Leader>db",
			function()
				vim.ui.input({ prompt = "Enter base branch name: " }, function(branch_name)
					local base_hash = vim.fn.system("git merge-base " .. branch_name .. " HEAD")
					vim.cmd("DiffviewOpen " .. base_hash .. " ...HEAD --imply-local")
				end)
			end,
			desc = "Diffview: PR for specific branch.",
		},
		{
			"<Leader>dl",
			"<cmd>DiffviewFileHistory --range=origin/HEAD...HEAD --right-only --no-merges<CR>",
			desc = "Diffview: Open large PR.",
		},
		{ "<Leader>df", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview: Open file history." },
		{ "<Leader>do", "<cmd>DiffviewOpen<CR>", desc = "Diffview: Open diffview." },
		{
			"<Leader>dp",
			"<cmd>DiffviewOpen origin/HEAD...HEAD --imply-local<CR>",
			desc = "⭐︎Diffview: Open PR.",
		},
	},
}
