-- VSCode関連の操作

local M = {}

function M.setup()
	-- キーマッピング
	local set = vim.keymap.set

	-- 現在のバッファをvscodeで開く
	set("n", "<Leader>vb", function()
		if vim.fn.executable("code") == 0 then
			vim.notify("code command not found.")
			return
		end

		local project_path = vim.fn.getcwd()
		local file_path = vim.fn.expand("%:p")
		vim.fn.jobstart({ "code", project_path, file_path }, { detach = true })
	end, { desc = "⭐︎VSCode: Open file." })

	-- 同じフォルダでvsocdeを開く
	set("n", "<Leader>vw", function()
		if vim.fn.executable("code") == 0 then
			vim.notify("code command not found.")
			return
		end

		local path = vim.fn.expand("%:p:h")
		vim.fn.jobstart({ "code", path }, { detach = true })
	end, { desc = "VSCode: Open folder." })
end

return M
