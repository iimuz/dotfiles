-- Markdownファイルのfront matterにあるlastmodを自動で保存日時に書き換える

vim.g.enable_auto_lastmod = true
vim.keymap.set("n", "<Plug>(auto-lastmod.enable)", function()
	vim.g.enable_auto_lastmod = true
	vim.notify("Enable auto-lastmod")
end, { desc = "AutoLastMod: Enable auto-lastmod" })
vim.keymap.set("n", "<Plug>(auto-lastmod.disable)", function()
	vim.g.enable_auto_lastmod = false
	vim.notify("Disable auto-lastmod")
end, { desc = "⭐︎AutoLastMod: Disable auto-lastmod" })

local function UpdateLastmod()
	if not vim.g.enable_auto_lastmod then
		return
	end

	local lastmod = os.time()
	local lastmod_str = os.date("%Y-%m-%dT%H:%M:%S", lastmod)
	local buf = vim.api.nvim_get_current_buf() -- 現在のバッファを取得
	local max_line = 10 -- 最大で読み込む行数
	local lines = vim.api.nvim_buf_get_lines(buf, 0, max_line, false) -- 先頭からmax_line行のみ確認する

	-- auto-saveから実行するときにファイルタイプを考慮しないので、ここで確認する
	local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
	if filetype ~= "markdown" then
		return
	end

	-- frontmatterを見つける
	-- ipairsは1から始まる
	local start_line, end_line = nil, nil
	for i, line in ipairs(lines) do
		if start_line ~= nil and line:match("^---$") then
			end_line = i
			break
		end

		if start_line == nil and line:match("^---$") then
			start_line = i
		end
	end
	if end_line == nil then
		end_line = 10
	end

	if start_line and end_line then
		-- lastmodフィールドを見つける
		local lastmod_line = nil
		for i = start_line, end_line do
			if lines[i]:match("^lastmod:.*$") then
				lastmod_line = i
				break
			end
		end

		if lastmod_line then
			local lastmod_view = "lastmod: " .. lastmod .. "  # " .. lastmod_str
			vim.notify("Update lastmod: " .. lastmod_str)
			vim.api.nvim_buf_set_lines(buf, lastmod_line - 1, lastmod_line, false, { lastmod_view })
		end
	end
end

-- ファイル保存時にUpdateLastmod()を実行
local augroup = vim.api.nvim_create_augroup("auto-update-lastmod", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = augroup,
	pattern = { "*.md" },
	callback = UpdateLastmod,
})
vim.api.nvim_create_autocmd({ "User" }, {
	group = augroup,
	pattern = { "AutoSaveWritePre" },
	callback = UpdateLastmod,
})
