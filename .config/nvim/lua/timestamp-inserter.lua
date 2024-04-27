-- Timestampを挿入するためのkeymap設定

-- 引数で指定したunix epochから日時文字列を生成する
local function timestamp2DateTimeStr(epoch)
	local date = os.date("%Y-%m-%d %H:%M:%S", epoch)
	return date
end

-- 引数で指定したunix epochから日付文字列を生成する
local function timestamp2DateStr(epoch)
	local date = os.date("%Y-%m-%d", epoch)
	return date
end

-- 引数で指定したunix epochから時刻文字列を生成する
local function timestamp2TimeStr(epoch)
	local date = os.date("%H:%M", epoch)
	return date
end

-- 現在のunix epochを取得する
local function getNowEpoch()
	local now = os.time()
	return now
end

-- キーマップの設定
-- Telescopeで選択することを想定している
local set = vim.keymap.set
set("n", "<Plug>(timestamp_inserter.now.datetime)", function()
	vim.api.nvim_put({ timestamp2DateTimeStr(getNowEpoch()) }, "c", true, true)
end, { desc = "TimestampInserter: Insert current date and time." })
set("n", "<Plug>(timestamp_inserter.now.date)", function()
	vim.api.nvim_put({ timestamp2DateStr(getNowEpoch()) }, "c", true, true)
end, { desc = "⭐︎TimestampInserter: Insert current date." })
set("n", "<Plug>(timestamp_inserter.now.time)", function()
	vim.api.nvim_put({ timestamp2TimeStr(getNowEpoch()) }, "c", true, true)
end, { desc = "⭐︎TimestampInserter: Insert current time." })
