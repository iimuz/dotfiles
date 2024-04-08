local opts = { noremap = true, silent = true }

-- Remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 自作
local set = vim.keymap.set
-- 現在開いているファイル名をクリップボードにコピーする
local function copyToClipboard(value)
	vim.notify("Copied: " .. value)
	vim.fn.setreg("+", value)
end
set("n", "<Plug>(self.copy.filename)", function()
	local filename = vim.fn.expand("%:t")
	copyToClipboard(filename)
end, { desc = "⭐︎Self: Copy file name." })
set("n", "<Plug>(self.copy.filename_without_suffix)", function()
	local filename = vim.fn.expand("%:t:r")
	copyToClipboard(filename)
end, { desc = "⭐︎Self: Copy file name without suffix." })
set("n", "<Plug>(self.copy.relative_filepath)", function()
	local filepath = vim.fn.expand("%:.")
	copyToClipboard(filepath)
end, { desc = "⭐︎Self: Copy relative file path." })
set("n", "<Plug>(self.copy.relative_filepath_from_home)", function()
	local filepath = vim.fn.expand("%:~")
	copyToClipboard(filepath)
end, { desc = "Self: Copy relative filepath from home." })
set("n", "<Plug>(self.copy.absolute_filepath)", function()
	local filepath = vim.fn.expand("%:p")
	copyToClipboard(filepath)
end, { desc = "Self: Copy absolute file path." })
-- TerminalのECSコマンドの設定
set("t", "<c-]>", "<c-\\><c-n>", { desc = "⭐︎Self: Escape from terminal." })

-- Quickfix
set("n", "<Plug>(quickfix.open)", "<cmd>copen<CR>", { desc = "⭐︎Quickfix: Open." })
set("n", "<Plug>(quickfix.close)", "<cmd>cclose<CR>", { desc = "⭐︎Quickfix: Close." })
set("n", "<Plug>(quickfix.next)", "<cmd>cnext<CR>", { desc = "⭐︎Quickfix: Next." })
set("n", "<Plug>(quickfix.previous)", "<cmd>cprevious<CR>", { desc = "⭐︎Quickfix: Previous." })
-- Location
set("n", "<Plug>(location.open)", "<cmd>lopen<CR>", { desc = "⭐︎Location: Open." })
set("n", "<Plug>(location.close)", "<cmd>lclose<CR>", { desc = "⭐︎Location: Close." })
set("n", "<Plug>(location.next)", "<cmd>lnext<CR>", { desc = "⭐︎Location: Next." })
set("n", "<Plug>(location.previous)", "<cmd>lprevious<CR>", { desc = "⭐︎Location: Previous." })

-- Fold
set("n", "<Plug>(fold.open.cursor)", "zo", { desc = "⭐︎Fold: Open under the cursor." })
set("n", "<Plug>(fold.open_all.cursor)", "zo", { desc = "⭐︎Fold: Open all under the cursor." })
set("n", "<Plug>(fold.close.cursor)", "zc", { desc = "⭐︎Fold: Close under the cursor." })
set("n", "<Plug>(fold.close_all.cursor)", "zc", { desc = "⭐︎Fold: Close all under the cursor." })
set("n", "<Plug>(fold.toggle.cursor)", "za", { desc = "Fold: Toggle under the cursor." })
set("n", "<Plug>(fold.toggle_all.cursor)", "za", { desc = "Fold: Toggle all under the cursor." })
set("n", "<Plug>(fold.open.window)", "zr", { desc = "Fold: Open in Window." })
set("n", "<Plug>(fold.open_all.window)", "zR", { desc = "⭐︎Fold: Open all in Window." })
set("n", "<Plug>(fold.close.window)", "zm", { desc = "Fold: Close in Window." })
set("n", "<Plug>(fold.close_all.window)", "zM", { desc = "⭐︎Fold: Close all in Window." })
