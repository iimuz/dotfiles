-- Timestampを挿入するためのkeymap設定

local M = {}

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
--
-- ショートカットキーはwhich-keyで設定するため何もしていない。
function M.setup() end

return M
