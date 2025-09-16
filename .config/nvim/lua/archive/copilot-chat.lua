-- CopilotC-Nvim/CopilotChat.nvim
-- see: <https://github.com/CopilotC-Nvim/CopilotChat.nvim>
--
-- Copilot Chatを利用できるようにするプラグイン
--
-- - 2024-07-02: VSCodeと併用しているので、このプラグインを利用しなくなったので無効化

return {
	"CopilotC-Nvim/CopilotChat.nvim",
	enabled = false,
	cmd = {
		"CopilotChatOpen",
	},
	dependencies = {
		{ "github/copilot.vim" },
		{ "nvim-lua/plenary.nvim" },
	},
	build = "make tiktoken", -- Only on MacOS or Linux
	opts = {},
}
