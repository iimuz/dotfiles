-- VSCode用の独自設定

-- `code`コマンドが利用できない場合は、以降の設定を行わない
if vim.fn.executable("code") == 0 then
	vim.notify("code command not found. Skip vscode settings.")
	return
end

local set = vim.keymap.set

-- 同じフォルダでvsocdeを開く
set("n", "<Plug>(vscode.open.folder)", function()
	local path = vim.fn.expand("%:p:h")
	vim.fn.jobstart({ "code", path }, { detach = true })
end, { desc = "VSCode: Open folder." })

-- 現在のバッファをvscodeで開く
set("n", "<Plug>(vscode.open.folder)", function()
	local project_path = vim.fn.getcwd()
	local file_path = vim.fn.expand("%:p")
	vim.fn.jobstart({ "code", project_path, file_path }, { detach = true })
end, { desc = "⭐︎VSCode: Open file." })
