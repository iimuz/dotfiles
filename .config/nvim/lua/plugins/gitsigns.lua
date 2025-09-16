-- gitsigns.nvimの設定
-- see: <https://github.com/lewis6991/gitsigns.nvim>
--
-- gitの変更点を可視化

-- vscodeから呼び出されているときは利用しない
local condition = vim.g.vscode == nil

return {
	"lewis6991/gitsigns.nvim",
	cond = condition,
	event = { "BufRead", "BufNewFile" },
	opts = {
		word_diff = false,
	},
	keys = {
		{
			"<Leader>gb",
			function()
				require("gitsigns").blame_line({ full = true })
			end,
			desc = "GitSigns: Blame line.",
		},
		{
			"<Leader>gB",
			function()
				require("gitsigns").toggle_current_line_blame()
			end,
			desc = "GitSigns: Toggle line blame.",
		},
		{
			"<Leader>gd",
			function()
				require("gitsigns").diffthis()
			end,
			desc = "GitSigns: Diff this.",
		},
		{
			"<Leader>gD",
			function()
				require("gitsigns").diffthis("~")
			end,
			desc = "GitSigns: Diff this (against HEAD~).",
		},
		{
			-- hoverがKを利用することが多いので。
			"<Leader>gk",
			function()
				require("gitsigns").preview_hunk()
			end,
			desc = "GitSigns: Preview hunk.",
		},
		{
			"<Leader>gn",
			function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					require("gitsigns").nav_hunk("next")
				end
			end,
			desc = "GitSigns: Next hunk.",
		},
		{
			"<Leader>gN",
			function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					require("gitsigns").nav_hunk("prev")
				end
			end,
			desc = "GitSigns: Previous hunk.",
		},
		{
			"<Leader>gq",
			"<cmd>Gitsign setqflist<CR>",
			desc = "GitSigns: Show hunks quickfix list.",
		},
		{
			"<Leader>gr",
			function()
				require("gitsigns").reset_hunk()
			end,
			desc = "GitSigns: Reset hunk.",
			mode = { "n", "v" },
		},
		{
			"<Leader>gR",
			function()
				require("gitsigns").reset_buffer()
			end,
			desc = "GitSigns: Reset buffer.",
		},
		{
			"<Leader>gs",
			function()
				require("gitsigns").stage_hunk()
			end,
			desc = "GitSigns: Stage hunk.",
			mode = { "n" },
		},
		{
			"<Leader>gs",
			function()
				require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end,
			desc = "GitSigns: Stage hunk.",
			mode = { "v" },
		},
		{
			"<Leader>gS",
			function()
				require("gitsigns").stage_buffer()
			end,
			desc = "GitSigns: Stage buffer.",
		},
		{
			"<Leader>gw",
			"<cmd>Gitsign toggle_word_diff<CR>",
			desc = "GitSigns: Toggle word diff.",
		},
	},
}
