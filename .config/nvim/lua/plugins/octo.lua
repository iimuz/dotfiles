-- pwntester/octo.nvim
-- see: <https://github.com/pwntester/octo.nvim>
--
-- GitHubの操作を行う

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

local set = vim.keymap.set
set("n", "<Plug>octo.load", "<cmd>Octo<CR>", { desc = "⭐︎Octo: Load octo plugin." })

return {
	"pwntester/octo.nvim",
	cond = condition,
	cmd = { "Octo" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("octo").setup({
			mappings_disable_default = true, -- defaultのショートカットキーは無効化
		})
	end,
}
