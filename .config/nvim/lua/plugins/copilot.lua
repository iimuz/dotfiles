-- github/copilot.vim
-- see: <https://github.com/github/copilot.vim>
--
-- GitHub Copilot Plugin.

return {
	"github/copilot.vim",
	cmd = "Copilot",
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
}
