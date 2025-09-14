-- rcarriga/nvim-notify
-- see: <https://github.com/rcarriga/nvim-notify>
--
-- 2025-09-14: Snacks.nvimのnotifyに入れ替え

return {
	"rcarriga/nvim-notify",
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
