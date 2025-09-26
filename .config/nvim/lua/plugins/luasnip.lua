-- L3MON4D3/LuaSnip
-- see: <https://github.com/L3MON4D3/LuaSnip>
--
-- Snippet管理プラグイン

-- LuaSnipのスニペット一覧をsnack.pickerで出力する
local function snacksPicker()
	local function finder()
		local luasnip = require("luasnip")
		local ft = vim.bo.filetype
		local snippets = luasnip.get_snippets(ft)

		local items = {}
		for _, snippet in pairs(snippets or {}) do
			table.insert(items, {
				text = snippet.trigger,
				description = snippet.desc or "",
				snippet = snippet,
			})
		end

		return items
	end

	local function format(item)
		return {
			{ item.text, "SnacksPickerLabel" },
			{ " ", virtual = true },
			{ item.description, "SnacksPickerComment" },
		}
	end

	local function confirm(picker, item)
		picker:close()
		if not item or not item.snippet then
			return
		end

		require("luasnip").snip_expand(item.snippet)
	end

	require("snacks").picker({
		finder = finder,
		format = format,
		confirm = confirm,
		layout = { preview = false },
	})
end

return {
	"L3MON4D3/LuaSnip",
	version = "v2.*", -- follow latest release.
	build = "make install_jsregexp", -- install jsregexp (optional!).
	event = { "VimEnter" },
	dependencies = { "rafamadriz/friendly-snippets" },
	config = function()
		local cwd = vim.fn.getcwd()
		local cwd_snippets_path = cwd .. "/.snippets"

		-- load friendly snippets and default
		require("luasnip.loaders.from_vscode").lazy_load()

		require("luasnip.loaders.from_vscode").lazy_load({
			paths = {
				"./snippets",
				"./snippets-private",
				cwd_snippets_path,
			},
		})
	end,
	keys = {
		{ "<Leader>n", snacksPicker, desc = "⭐︎Luasnip: Open snippet list." },
	},
}
