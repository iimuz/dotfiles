-- Saghen/blink.cmp
-- see: <https://github.com/Saghen/blink.cmp>
--
-- Completion.

return {
	"saghen/blink.cmp",
	version = "1.*",
	dependencies = { "L3MON4D3/LuaSnip" },
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		-- All presets have the following mappings:
		-- C-space: Open menu or open docs if already open
		-- C-n/C-p or Up/Down: Select next/previous item
		-- C-e: Hide menu
		-- C-k: Toggle signature help (if signature.enabled = true)
		keymap = {
			preset = "default",
			["<C-u>"] = { "scroll_documentation_up", "fallback" }, -- = [C-b]
			["<C-d>"] = { "scroll_documentation_down", "fallback" }, -- = [C-f]
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		completion = { documentation = { auto_show = true } },
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
		snippets = { preset = "luasnip" },
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
