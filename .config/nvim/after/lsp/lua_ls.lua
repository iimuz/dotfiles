-- LuaのLSP設定

---@type vim.lsp.Config
return {
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},
		},
	},
}
