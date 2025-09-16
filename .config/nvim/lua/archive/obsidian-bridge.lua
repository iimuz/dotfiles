-- oflisback/obsidian-bridge.nvim
--
-- neovimで開いているファイルをobsidianで同期して表示する。
--
-- scroll syncを利用するために導入しようとしたが、対応手順が多かったので見送り。

return {
	"oflisback/obsidian-bridge.nvim",
	enabled = false,
	dependencies = { "nvim-telescope/telescope.nvim" },
	config = function()
		require("obsidian-bridge").setup({
			obsidian_server_address = "https://localhost:27124",
			scroll_sync = false,
		})
	end,
	event = {
		"BufReadPre *.md",
		"BufNewFile *.md",
	},
	lazy = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
}
