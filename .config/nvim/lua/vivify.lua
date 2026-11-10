-- Vivifyで今のファイルを見る (URLのコピーとOrcaでの表示)

local orca = require("orca")

local M = {}

M.VIEWER_PREFIX = "http://localhost:31622/viewer/"

local PORT = 31622
local POLL_INTERVAL_MS = 100
local READY_TIMEOUT_MS = 5000

function M.viewer_url(abs_path)
	local encoded = abs_path:sub(2):gsub("[^A-Za-z0-9/._~!*'()-]", function(c)
		return string.format("%%%02X", c:byte())
	end)
	return M.VIEWER_PREFIX .. encoded
end

function M.wait_ready(on_ready)
	local deadline = vim.uv.now() + READY_TIMEOUT_MS
	local function attempt()
		local client = vim.uv.new_tcp()
		client:connect("127.0.0.1", PORT, function(err)
			client:close()
			vim.schedule(function()
				if not err then
					on_ready()
				elseif vim.uv.now() >= deadline then
					vim.notify("vivify-server did not become ready.", vim.log.levels.WARN)
				else
					vim.defer_fn(attempt, POLL_INTERVAL_MS)
				end
			end)
		end)
	end
	attempt()
end

local function current_file()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" or vim.uv.fs_stat(path) == nil then
		vim.notify("Buffer has no file on disk.", vim.log.levels.WARN)
		return nil
	end
	return path
end

local function start_server()
	if vim.fn.executable("vivify-server") ~= 1 then
		vim.notify("vivify-server command not found.", vim.log.levels.WARN)
		return false
	end

	-- 起動の直後はブラウザが未接続で、既定の10秒ではURLを貼る前に止まる
	local job = vim.fn.jobstart({ "vivify-server" }, { detach = true, env = { VIV_TIMEOUT = "300000" } })
	if job <= 0 then
		vim.notify("Failed to start vivify-server.", vim.log.levels.WARN)
		return false
	end
	return true
end

function M.setup()
	vim.keymap.set("n", "<Leader>mv", function()
		local path = current_file()
		if path == nil or not start_server() then
			return
		end

		local url = M.viewer_url(path)
		vim.fn.setreg("+", url)
		vim.notify("Copied: " .. url, vim.log.levels.INFO)
	end, { desc = "Vivify: Copy viewer URL of current file." })

	vim.keymap.set("n", "<Leader>mb", function()
		local path = current_file()
		if path == nil then
			return
		end
		if orca.worktree_id() == nil then
			vim.notify("Not inside an Orca terminal.", vim.log.levels.WARN)
			return
		end
		if not start_server() then
			return
		end

		M.wait_ready(function()
			orca.show_url(M.viewer_url(path), M.VIEWER_PREFIX)
		end)
	end, { desc = "Vivify: Open current file in Orca browser split." })
end

return M
