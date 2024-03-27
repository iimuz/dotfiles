-- Zettelkasten用の独自設定
--
-- 複数のプラグインに依存するため、プラグインの削除や追加に依存する

local set = vim.keymap.set
set("n", "<Plug>(zettelkasten.grep_title)", function()
	require("telescope.builtin").live_grep()
	-- title検索をするための共通部分を挿入
	vim.cmd("normal! ititle: .*")
end, { desc = "⭐︎Zettelkasten: Search title in workspace." })
