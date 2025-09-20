-- folke/which-key.nvim
-- see: <https://github.com/folke/which-key.nvim>
--
-- ショートカットキーのコマンドパレット
--
-- ## ショートカットキーに登録するときの簡易ルール
--
-- - 各pluginのshortcut keyは、pluginの設定ファイルに記載する。
-- - groupおよびtopのshortcut keyは、ここに記載する。
-- - descriptionには、"⭐︎"を付けることでTelescopeで検索した時に優先して表示される。

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	config = function()
		local wk = require("which-key")
		wk.setup({
			preset = "helix",
		})
		wk.add({
			{ "<Leader>a", group = "Avante" },
			{ "<Leader>A", group = "AutoLastmod" },
			{ "<Leader>b", group = "Trouble" },
			{ "<Leader>B", group = "Tab" },
			{ "<Leader>c", group = "Clipboard" },
			{ "<Leader>C", group = "Conform" },
			{ "<Leader>d", group = "Diffview" },
			{ "<Leader>e", group = "Neotest" },
			{ "<Leader>f", group = "File" },
			{ "<Leader>F", group = "FrontMatterSearcher" },
			{ "<Leader>g", group = "GitSigns" },
			{ "<Leader>G", group = "Copilot" },
			-- <Leader>hはmakrdown-hop-linksで利用しているため、ここでは利用しない
			{ "<Leader>H", group = "McpHub" },
			{ "<Leader>k", group = "Kulala" },
			{ "<Leader>K", group = "TreeSitter" }, -- Tree = 木 = [K]i
			{ "<Leader>l", group = "LSP" }, -- 全てではないが一部のLeaderキーを設定するためLSPで利用
			{ "<Leader>L", "<cmd>Lazy<CR>", desc = "⭐︎Lazy: Show Lazy UI." }, -- 全体の管理なので元の所で設定する方法がわからないのでここに記載
			{ "<Leader>m", group = "Markdown" },
			{ "<Leader>M", group = "Mason" },
			-- <Leader>nはlua-snipで利用しているため、ここでは利用しない
			-- <Leader>Nはnvim-lintで利用しているため、ここでは利用しない
			{ "<Leader>o", group = "Outline" },
			{ "<Leader>O", group = "Octo" },
			{ "<Leader>Oc", group = "Comment" },
			{ "<Leader>Og", group = "Gist" },
			{ "<Leader>Oe", group = "Repository" },
			{ "<Leader>Oi", group = "Issue" },
			{ "<Leader>Op", group = "PR" },
			{ "<Leader>Or", group = "Review" },
			{ "<Leader>Ot", group = "Thread" },
			-- <Leader>pはFilePalletteで利用しているため、ここでは利用しない
			-- <Leader>PはCommandPalletteで利用しているため、ここでは利用しない
			{ "<Leader>q", group = "Quickfix and Location list" },
			{ "<Leader>ql", group = "Location list" },
			{ "<Leader>qq", group = "Quickfix" },
			{ "<Leader>r", group = "Project" }, -- local project固有のキーマップ用
			{ "<Leader>R", group = "RenderMarkdown" },
			-- <Leader>uはAutoSaveで利用しているため、ここでは利用しない
			{ "<Leader>t", group = "Telescope" },
			{ "<Leader>tl", group = "LSP" },
			{ "<Leader>T", group = "ToggleTerm" },
			{ "<Leader>u", group = "GitLinker" }, -- GitLinker -> URL
			{ "<Leader>U", group = "ClaudeCode" },
			{ "<Leader>v", group = "VSCode" },
			{ "<Leader>w", group = "Snacks" }, -- "Snacks" -> "snack" -> "お菓子" -> "軽食"という連想から、w=軽い、w=簡単
		})
	end,
}
