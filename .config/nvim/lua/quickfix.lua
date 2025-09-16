-- quickfix and location list management

local M = {}

function M.setup()
	-- キーマッピング
	local set = vim.keymap.set
	set("n", "<Leader>qln", "<cmd>lnext<CR>", { desc = "⭐︎Location: Next." })
	set("n", "<Leader>qlN", "<cmd>lprevious<CR>", { desc = "⭐︎Location: Previous." })
	set("n", "<Leader>qlo", "<cmd>lopen<CR>", { desc = "⭐︎Location: Open." })
	set("n", "<Leader>qlx", "<cmd>lclose<CR>", { desc = "⭐︎Location: Close." })
	set("n", "<Leader>qqn", "<cmd>cnext<CR>", { desc = "⭐︎Quickfix: Next." })
	set("n", "<Leader>qqN", "<cmd>cprevious<CR>", { desc = "⭐︎Quickfix: Previous." })
	set("n", "<Leader>qqo", "<cmd>copen<CR>", { desc = "⭐︎Quickfix: Open." })
	set("n", "<Leader>qqx", "<cmd>cclose<CR>", { desc = "⭐︎Quickfix: Close." })
end

return M
