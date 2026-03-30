-- nvim-treesitter
-- see: <https://github.com/nvim-treesitter/nvim-treesitter>
--
-- main ブランチは完全な非互換リライト (Neovim 0.12+ 必須)。
-- ensure_installed, require("nvim-treesitter.configs").setup() は廃止。
-- highlight/indent は FileType autocmd で有効化する。

-- VSCodeから利用した場合は無効化する
local condition = vim.g.vscode == nil

local parsers = {
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
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	cond = condition,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup({})

		-- パーサーをインストール (非同期)
		for _, parser in ipairs(parsers) do
			require("nvim-treesitter").install(parser)
		end

		-- パーサー名からファイルタイプパターンを構築
		local patterns = {}
		for _, parser in ipairs(parsers) do
			local filetypes = vim.treesitter.language.get_filetypes(parser)
			for _, ft in ipairs(filetypes) do
				table.insert(patterns, ft)
			end
		end

		-- FileType autocmd で highlight/indent を有効化
		vim.api.nvim_create_autocmd("FileType", {
			pattern = patterns,
			callback = function(args)
				vim.treesitter.start(args.buf)
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})

		-- foldをtreesitterで行う
		vim.opt.foldmethod = "expr"
		vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.opt.foldenable = false -- デフォルトでは折りたたみを無効にする
	end,
	keys = {
		{ "<Leader>Ku", "<cmd>TSUpdate<CR>", desc = "TreeSitter: Update Tree-Sitter" },
	},
}
