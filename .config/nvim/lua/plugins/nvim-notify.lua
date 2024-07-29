-- rcarriga/nvim-notify
-- see: <https://github.com/rcarriga/nvim-notify>

-- VSCodeから利用する場合は無効化
local condition = vim.g.vscode == nil

return {
	"rcarriga/nvim-notify",
	cond = condition,
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("notify").setup({
			render = "compact",
			top_down = false, -- 通知は下部に出力
		})
		vim.notify = require("notify")

		-- Telescopeに拡張機能を追加
		require("telescope").load_extension("notify")
	end,
}
