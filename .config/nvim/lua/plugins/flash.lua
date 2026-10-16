-- folke/flash.nvim
-- see: <https://github.com/folke/flash.nvim>
--
-- カーソル移動をラベルで行う。

local function migemo_mode(str)
	-- skip に本文に現れない文字を返し、ラベルの候補を除く走査を事実上止める。
	-- Migemo の正規表現で走査させるとバッファ全体をなめて遅い
	local skip = [[\%x01]]
	-- ローマ字 1 文字の Migemo の正規表現は数 KB になり、flash は一致ごとにコンパイルし直すので遅い。
	-- 1 文字の間は素の文字で探す
	if vim.fn.strchars(str) < 2 then
		return [[\c\V]] .. vim.fn.escape(str, [[\]]), skip
	end
	local migemo = require("luamigemo")
	return [[\c]] .. migemo.query(str, migemo.RXOP_VIM), skip
end

local function jump(multi_window)
	require("flash").jump({
		search = { multi_window = multi_window, mode = migemo_mode },
		-- skip を止めたので、小文字のラベルはローマ字の続きと区別できない。
		-- ラベルを大文字だけにし、小文字は検索語を伸ばす
		labels = "ASDFGHJKLQWERTYUIOPZXCVBNM",
		-- 既定の reuse は小文字のラベルだけを使い回すので、大文字のラベルが打鍵のたびに付け直される
		label = { reuse = "all" },
	})
end

return {
	"folke/flash.nvim",
	dependencies = { { "delphinus/luamigemo", version = "*" } },
	opts = {
		modes = {
			-- 既定では char モードが f / F / t / T / ; / , を奪う。t / T / ; / , を Vim 標準のまま残すため無効にする
			char = { enabled = false },
		},
	},
	keys = {
		{
			"f",
			function()
				jump(false)
			end,
			mode = { "n", "x", "o" },
			desc = "Flash: Jump in current window.",
		},
		{
			"F",
			function()
				jump(true)
			end,
			mode = { "n", "x", "o" },
			desc = "Flash: Jump in all windows.",
		},
	},
}
