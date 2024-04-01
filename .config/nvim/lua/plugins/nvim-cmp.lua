-- hrsh7th/nvim-cmp
-- see: <>
--
-- Completion

local condition = vim.g.vscode == nil

return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	cond = condition,
	dependencies = {
		{ "hrsh7th/cmp-buffer" }, -- 開いているバッファからのキーワード補完
		{ "hrsh7th/cmp-nvim-lsp" }, -- LSPからの補完
		{ "hrsh7th/cmp-path" }, -- パス補完
		{ "petertriho/cmp-git" }, -- git issueなどの補完
		{ "saadparwaiz1/cmp_luasnip" }, -- luasnipからの補完
		-- { "hrsh7th/cmp-emoji" },
		-- { "hrsh7th/cmp-vsnip" },
		-- { "onsails/lspkind.nvim" },
	},
	config = function()
		local cmp = require("cmp")
		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body) -- For `luasnip`
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-d>"] = cmp.mapping.scroll_docs(-4),
				["<C-u>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				["<CR>"] = cmp.mapping.confirm({ select = true }),
			}),
			sources = cmp.config.sources({
				-- sourcesの順番に補完候補が現れることに注意。
				-- LSPからの補完
				-- see: <https://github.com/hrsh7th/cmp-nvim-lsp>
				{ name = "nvim_lsp" },
				-- パス補完
				-- see: <https://github.com/hrsh7th/cmp-path>
				{ name = "path" },
				-- git issueなどの補完
				-- see: <https://github.com/petertriho/cmp-git>
				{ name = "git" },
				-- luasnipからの補完
				{ name = "luasnip" },
				-- 開いているバッファからのキーワード補完
				-- see: <https://github.com/hrsh7th/cmp-buffer>
				{ name = "buffer" },
			}),
		})

		-- cmp.setup.cmdline({ '/', '?' }, {
		--   mapping = cmp.mapping.preset.cmdline(),
		--   sources = {
		--     { name = 'buffer' }
		--   }
		-- })
	end,
}
