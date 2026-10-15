-- folke/noice.nvim
-- see: <https://github.com/folke/noice.nvim>
--
-- UI

return {
	"folke/noice.nvim",
	event = "VeryLazy",
	-- vim.notify は noice が受けて履歴に残し、表示は noice の snacks backend 経由で
	-- snacks.notifier に任せる (LazyVim と同じ分担)。snacks の notifier を無効にすると、
	-- nvim-notify は入れていないので、表示は noice の mini view に落ちる
	opts = {},
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
}
