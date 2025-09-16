-- ravitemer/mcphub.nvim
-- see: <https://github.com/ravitemer/mcphub.nvim>
--
-- streamlines how you develop with LLMs, in Neovim.

return {
	"ravitemer/mcphub.nvim",
	lazy = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	-- build = "npm install -g mcp-hub@latest", -- mise側でツールをインストール
	opts = {
		config = vim.fn.expand("~/.config/mcphub/servers.json"),
	},
	keys = {
		{ "<Leader>H", "<cmd>McpHub<CR>", desc = "⭐︎McpHub: Open." },
	},
}
