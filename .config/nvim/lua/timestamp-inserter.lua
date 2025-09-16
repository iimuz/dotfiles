-- Timestampを挿入するためのkeymap設定

local M = {}

-- VSCodeから利用する場合は無効化
if vim.g.vscode ~= nil then
	function M.setup() end
	return M
end

-- 引数で指定したunix epochから日時文字列を生成する
function M.timestamp2DateTimeStr(epoch)
	local date = os.date("%Y-%m-%d %H:%M:%S", epoch)
	return date
end

-- 引数で指定したunix epochから日付文字列を生成する
function M.timestamp2DateStr(epoch)
	local date = os.date("%Y-%m-%d", epoch)
	return date
end

-- 引数で指定したunix epochから時刻文字列を生成する
function M.timestamp2TimeStr(epoch)
	local date = os.date("%H:%M", epoch)
	return date
end

-- 現在のunix epochを取得する
function M.getNowEpoch()
	local now = os.time()
	return now
end

-- 初期化処理
function M.setup()
	-- キーマッピング
	local set = vim.keymap.set
	set("n", "<Leader>ja", function()
		local ti = require("timestamp-inserter")
		vim.api.nvim_put({ ti.timestamp2DateTimeStr(ti.getNowEpoch()) }, "c", true, true)
	end, { desc = "TimestampInserter: Insert current date and time." })
	set("n", "<Leader>jd", function()
		local ti = require("timestamp-inserter")
		vim.api.nvim_put({ ti.timestamp2DateStr(ti.getNowEpoch()) }, "c", true, true)
	end, { desc = "⭐︎TimestampInserter: Insert current date." })
	set("n", "<Leader>jt", function()
		local ti = require("timestamp-inserter")
		vim.api.nvim_put({ ti.timestamp2TimeStr(ti.getNowEpoch()) }, "c", true, true)
	end, { desc = "⭐︎TimestampInserter: Insert current time." })
end

return M
