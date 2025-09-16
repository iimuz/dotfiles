-- Clipboard manager for Neovim

local M = {}

-- 指定した値をクリップボードにコピーする
local function copyToClipboard(value)
	--  zellijからnvimを利用するとチラつくケースがあったので修正
	-- vim.notify("Copied: " .. value)
	vim.fn.setreg("+", value)
end

function M.setup()
	-- キーマッピング
	local set = vim.keymap.set
	set("n", "<Leader>ca", function()
		copyToClipboard(vim.fn.expand("%:p"))
	end, { desc = "Clipboard: Copy absolute file path." })
	set("n", "<Leader>ch", function()
		copyToClipboard(vim.fn.expand("%:~"))
	end, { desc = "Clipboard: Copy relative filepath from home." })
	set("n", "<Leader>cn", function()
		copyToClipboard(vim.fn.expand("%:t"))
	end, { desc = "⭐︎Clipboard: Copy file name." })
	set("n", "<Leader>cr", function()
		copyToClipboard(vim.fn.expand("%:."))
	end, { desc = "⭐︎Clipboard: Copy relative file path." })
	set("n", "<Leader>cw", function()
		copyToClipboard(vim.fn.expand("%:t:r"))
	end, { desc = "⭐︎Clipboard: Copy file name without suffix." })
end

return M
