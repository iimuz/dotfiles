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
		command = "~/.config/claude/local/claude",
	},
}
