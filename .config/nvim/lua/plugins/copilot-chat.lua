-- CopilotC-Nvim/CopilotChat.nvim
-- see: <https://github.com/CopilotC-Nvim/CopilotChat.nvim>
--
-- Copilot Chatを利用できるようにするプラグイン
--
-- - 2024-07-02: VSCodeと併用しているので、このプラグインを利用しなくなったので無効化

-- VSCodeから利用する場合は無効化
local condition = vim.g.vscode == nil

return {
	"CopilotC-Nvim/CopilotChat.nvim",
	cond = condition,
	enabled = true,
	cmd = {
		"CopilotChatOpen",
	},
	dependencies = {
		{ "github/copilot.vim" },
		{ "nvim-lua/plenary.nvim" },
	},
	build = "make tiktoken", -- Only on MacOS or Linux
	opts = {},
	-- config = function()
	-- 	require("CopilotChat").setup()
	-- end,
}
