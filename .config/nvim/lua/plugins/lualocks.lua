-- vhyrro/luarocks.nvim
-- see: <https://github.com/vhyrro/luarocks.nvim>
--
-- Easily install luarocks with lazy.nvim
--
-- 2025-04-11: lazy.nvimが依存しておりエラーが出ているので追加

return {
	"vhyrro/luarocks.nvim",
	priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
	config = true,
	build = function()
		require("luarocks").setup()
		vim.fn.system("luarocks --tree=" .. vim.fn.stdpath("data") .. "/lazy/luarocks.nvim/.rocks install dkjson")
	end,
}
