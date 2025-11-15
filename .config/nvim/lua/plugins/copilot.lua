-- zbirenbaum/copilot.lua
-- see: <https://github.com/zbirenbaum/copilot.lua>
--
-- GitHub Copilot Plugin.
--
-- - 補完は、 blink.cmp を利用して実施

return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	dependencies = {
		-- "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality だが NES は利用していないので無効化
	},
	keys = {
		{ "<Leader>Ge", "<cmd>Copilot enable<CR>", desc = "Copilot: Enable." },
		{ "<Leader>Gd", "<cmd>Copilot disable<CR>", desc = "Copilot: Disable." },
		{ "<Leader>Gi", "<cmd>Copilot signin<CR>", desc = "Copilot: Signin." },
		{ "<Leader>Go", "<cmd>Copilot signout<CR>", desc = "Copilot: Signout." },
		{ "<Leader>Gp", "<cmd>Copilot panel<CR>", desc = "Copilot: Show panel." },
		{ "<Leader>Gr", "<cmd>Copilot restart<CR>", desc = "Copilot: Restart." },
		{ "<Leader>Gs", "<cmd>Copilot status<CR>", desc = "⭐︎Copilot: Show status." },
		{ "<Leader>Gu", "<cmd>Copilot setup<CR>", desc = "Copilot: Setup." },
	},
	opts = {
		panel = { enabled = false },
	},
}
