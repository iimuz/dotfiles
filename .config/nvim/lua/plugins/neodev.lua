-- folke/neodev.nvim
-- see: <https://github.com/folke/neodev.nvim>
--
-- neovimのluaを書くときに補完などができるようにする

return {
	"folke/neodev.nvim",
	config = function()
		require("neodev").setup({})

		local lspconfig = require("lspconfig")
		lspconfig.lua_ls.setup({
			settings = {
				Lua = {
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		})
	end,
}
