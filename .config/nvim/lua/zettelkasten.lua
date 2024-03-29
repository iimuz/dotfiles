-- Zettelkasten用の独自設定
--
-- 複数のプラグインに依存するため、プラグインの削除や追加に依存する

local set = vim.keymap.set

-- `title:`までを検索対象として追加したlive_grep
set("n", "<Plug>(zettelkasten.grep_title)", function()
	require("telescope.builtin").live_grep()
	-- title検索をするための共通部分を挿入
	vim.cmd("normal! ititle: .*")
end, { desc = "⭐︎Zettelkasten: Search title in workspace." })

-- 一時ファイルを作成して開く
set("n", "<Plug>(zettelkasten.create_and_open_temp_file)", function()
	local filepath = vim.fn.tempname()
	vim.cmd("edit " .. filepath)
end, { desc = "⭐︎Zettelkasten: Create and open temporary file." })
