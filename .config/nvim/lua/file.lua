-- File management for Neovim

local M = {}

function M.setup()
	-- キーマッピング
	local set = vim.keymap.set
	set("n", "<Leader>ft", function()
		local filepath = vim.fn.tempname()
		vim.cmd("edit " .. filepath)
	end, { desc = "⭐︎File: Create and open temporary file." })
end

return M
