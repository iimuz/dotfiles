-- nvim-treesitter
-- see: <https://github.com/nvim-treesitter/nvim-treesitter>

-- VSCodeから利用した場合は無効化する
local condition = vim.g.vscode == nil

return {
	"nvim-treesitter/nvim-treesitter",
	cond = condition,
	build = ":TSUpdate",
	config = function()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = {
				"bash",
				"c",
				"comment",
				"cpp",
				"css",
				"csv",
				"cuda",
				"diff",
				"dockerfile",
				"git_config",
				"git_rebase",
				"gitattributes",
				"gitcommit",
				"gitignore",
				"go",
				"gomod",
				"gosum",
				"gowork",
				"graphql",
				"html",
				"http",
				"ini",
				"javascript",
				"jq",
				"jsdoc",
				"json",
				"jsonc",
				"lua",
				"make",
				"markdown",
				"markdown_inline",
				"mermaid",
				"python",
				"rust",
				"sql",
				"toml",
				"typescript",
				"vim",
				"vimdoc",
				"xml",
				"yaml",
			},
			sync_install = false,
			highlight = { enable = true },
			indent = { enable = true },
		})
		-- foldをtreesitterで行う
		vim.opt.foldmethod = "expr"
		vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
		vim.opt.foldenable = false -- デフォルトでは折りたたみを無効にする
	end,
	keys = {
		{ "<Leader>Ke", "<cmd>TSContextEnable<CR>", desc = "TreeSitter: Enable Context." },
		{ "<Leader>Kd", "<cmd>TSContextDisable<CR>", desc = "TreeSitter: Disable Context." },
		{
			"<Leader>Kj",
			function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end,
			desc = "TreeSitter: Jumping to context(upwards).",
		},
		{ "<Leader>Ku", "<cmd>TSUpdate<CR>", desc = "TreeSitter: Update Tree-Sitter" },
	},
}
