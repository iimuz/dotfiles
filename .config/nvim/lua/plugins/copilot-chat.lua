-- CopilotC-Nvim/CopilotChat.nvim
-- see: <https://github.com/CopilotC-Nvim/CopilotChat.nvim>
--
-- Copilot Chatを利用できるようにするプラグイン

-- VSCodeから利用する場合は無効化
local condition = vim.g.vscode == nil

return {
	"CopilotC-Nvim/CopilotChat.nvim",
	branch = "canary",
	cond = condition,
	cmd = {
		"CopilotChatOpen",
	},
	dependencies = {
		{ "github/copilot.vim" },
		{ "nvim-lua/plenary.nvim" },
	},
	config = function()
		require("CopilotChat").setup()
	end,
}
