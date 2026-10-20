-- Vivifyで今のファイルを見るURLのコピー

local M = {}

function M.viewer_url(abs_path)
	local encoded = abs_path:sub(2):gsub("[^A-Za-z0-9/._~!*'()-]", function(c)
		return string.format("%%%02X", c:byte())
	end)
	return "http://localhost:31622/viewer/" .. encoded
end

function M.setup()
	vim.keymap.set("n", "<Leader>mv", function()
		local path = vim.api.nvim_buf_get_name(0)
		if path == "" or vim.uv.fs_stat(path) == nil then
			vim.notify("Buffer has no file on disk.", vim.log.levels.WARN)
			return
		end
		if vim.fn.executable("vivify-server") ~= 1 then
			vim.notify("vivify-server command not found.", vim.log.levels.WARN)
			return
		end

		-- 起動の直後はブラウザが未接続で、既定の10秒ではURLを貼る前に止まる
		local job = vim.fn.jobstart({ "vivify-server" }, { detach = true, env = { VIV_TIMEOUT = "300000" } })
		if job <= 0 then
			vim.notify("Failed to start vivify-server.", vim.log.levels.WARN)
			return
		end

		local url = M.viewer_url(path)
		vim.fn.setreg("+", url)
		vim.notify("Copied: " .. url, vim.log.levels.INFO)
	end, { desc = "Vivify: Copy viewer URL of current file." })
end

return M
