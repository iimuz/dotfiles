-- CopilotC-Nvim/CopilotChat.nvim
-- see: <https://github.com/CopilotC-Nvim/CopilotChat.nvim>
--
-- Copilot Chatを利用できるようにするプラグイン

-- VSCodeから利用する場合は無効化
local condition = vim.g.vscode == nil

local set = vim.keymap.set
set("n", "<Plug>(CopilotChat.open)", "<cmd>CopilotChatOpen<CR>", { desc = "⭐︎CopilotChat: Open chat window." })

return {
	{
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
			local chat = require("CopilotChat")
			chat.setup()

			local set = vim.keymap.set
			-- Close chat window
			set("n", "<Plug>(CopilotChat.close)", chat.close, { desc = "CopilotChat - Close chat window." })
			-- Reset chat window
			set("n", "<Plug>(CopilotChat.reset)", chat.reset, { desc = "CopilotChat - Reset chat window." })
			-- Inline chat
			set("n", "<Plug>(CopilotChat.inline_chat)", function()
				chat.toggle({
					window = {
						layout = "float",
						title = "CopilotChat - Inline Chat",
						relative = "cursor",
						width = 1,
						height = 0.4,
						row = 1,
					},
				})
			end, { desc = "⭐︎CopilotChat: Inline chat" })
			-- Quick chat
			set("n", "<Plug>(CopilotChat.quick_chat)", function()
				local input = vim.fn.input("Quick Chat: ")
				if input ~= "" then
					chat.ask(input, { selection = require("CopilotChat.select").buffer })
				end
			end, { desc = "⭐︎CopilotChat: Quick chat" })
		end,
	},
}
