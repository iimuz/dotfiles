-- greggh/claude-code
-- see: <https://github.com/greggh/claude-code.nvim>
--
-- Claude codeの統合

return {
	"greggh/claude-code.nvim",
	cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume" },
	dependencies = {
		"nvim-lua/plenary.nvim", -- Required for git operations
	},
	opts = {
		window = {
			position = "rightbelow vsplit",
		},
	},
	keys = {
		{
			"<Leader>Uc",
			"<cmd>ClaudeCodeContinue<CR>",
			desc = "ClaudeCode: Resume the most recent conversation.",
			mode = { "n" },
		},
		{
			"<Leader>Uo",
			"<cmd>ClaudeCode<CR>",
			desc = "ClaudeCode: Open.",
			mode = { "n" },
		},
		{
			"<Leader>Ur",
			"<cmd>ClaudeCodeResume<CR>",
			desc = "ClaudeCode: Display an interactive conversation picker.",
			mode = { "n" },
		},
	},
}
