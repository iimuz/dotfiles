-- stevearc/aerial
-- see: <https://github.com/stevearc/aerial.nvim>
--
-- Outline表示
--
-- 2024-05-31:
-- アウトライン表示を呼び出すとクラッシュすることが多発したので利用を停止。
-- outline.nvimを代わりに利用している。
--
-- 2025-09-08:
-- telescope連携でoutlineを取得するときに利用している。

-- 起動用のキーマッピング
local set = vim.keymap.set
return {
	"stevearc/aerial.nvim",
	-- enabled = false,
	cmd = {
		"AerialToggle",
		"AerialOpen",
		"AerialNavOpen",
	},
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {},
	config = function()
		local set = vim.keymap.set
		require("aerial").setup({
			-- Priority list of preferred backends for aerial.
			-- This can be a filetype map (see :help aerial-filetype-map)
			backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },
			-- optionally use on_attach to set keymaps when aerial has attached to a buffer
			on_attach = function(bufnr)
				-- Jump forwards/backwards with '{' and '}'
				set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
				set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
			end,
		})

		-- Telescope拡張
		require("telescope").load_extension("aerial")
	end,
	keys = {
		{ "<Leader>ot", "<cmd>Telescope aerial<CR>", desc = "Aerial: Open using telescope." },
	},
}
