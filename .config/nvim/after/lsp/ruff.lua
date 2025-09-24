-- ruffに関するLSP設定
--
-- ruffとpyrightなどを併用する場合
-- see: <https://github.com/astral-sh/ruff-lsp?tab=readme-ov-file#example-neovim>

---@type vim.lsp.Config
return {
	init_options = {
		settings = {
			-- Any extra CLI arguments for "ruff" go here.
			args = {},
		},
	},
	on_attach = function(client, _)
		if client.name == "ruff" then
			-- Disable hover in favor of Pyright
			client.server_capabilities.hoverProvider = false
		end
	end,
}
