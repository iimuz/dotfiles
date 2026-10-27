-- Saghen/blink.cmp
-- see: <https://github.com/Saghen/blink.cmp>
--
-- Completion.

return {
	"saghen/blink.cmp",
	version = "1.*",
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
			default = { "snippets", "lsp", "path", "buffer" },
			providers = {
				snippets = {
					opts = {
						search_paths = {
							vim.fn.stdpath("config") .. "/snippets",
							vim.fn.getcwd() .. "/.snippets",
						},
					},
				},
			},
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
