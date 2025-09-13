-- Tab management

local M = {}

function M.setup()
	-- キーマッピング
	local set = vim.keymap.set
	set("n", "<Leader>Bn", "<cmd>tabnext<CR>", { desc = "⭐︎Tab: Move next tab." })
	set("n", "<Leader>BN", "<cmd>tabprevious<CR>", { desc = "⭐︎Tab: Move previous tab." })
	set("n", "<Leader>Bo", "<cmd>tabnew<CR>", { desc = "⭐︎Tab: Open a new tab." })
	set("n", "<Leader>Bx", "<cmd>tabclose<CR>", { desc = "⭐︎Tab: Close tab." })
end

return M
