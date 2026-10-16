-- folke/flash.nvim
-- see: <https://github.com/folke/flash.nvim>
--
-- カーソル移動をラベルで行う。

return {
	"folke/flash.nvim",
	opts = {
		modes = {
			-- 既定では char モードが t / T / ; / , を奪うので、Vim 標準のまま残すため無効にする
			char = { enabled = false },
		},
	},
	keys = {
		{
			"f",
			function()
				require("flash").jump({ search = { multi_window = false } })
			end,
			mode = { "n", "x", "o" },
			desc = "Flash: Jump in current window.",
		},
		{
			"F",
			function()
				require("flash").jump({ search = { multi_window = true } })
			end,
			mode = { "n", "x", "o" },
			desc = "Flash: Jump in all windows.",
		},
	},
}
