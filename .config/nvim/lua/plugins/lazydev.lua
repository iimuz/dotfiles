-- folke/lazydev.nvim
-- see: <https://github.com/folke/lazydev.nvim>
--
-- neovimのluaを書くときに補完などができるようにする
-- neodev.nvimの後継

return {
	"folke/lazydev.nvim",
	ft = "lua",
	opts = {
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	},
}
