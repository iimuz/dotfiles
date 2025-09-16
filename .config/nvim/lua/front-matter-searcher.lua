-- front matterを利用した検索コマンド
--
-- Snacks.nvimに依存している。

local M = {}

-- rgでfront matterを取得して、yqでJSONに変換して返す
--
-- ## 処理の流れ
--
-- ### front matterの抽出
-- rgで"---"で囲まれた部分をfront matterとして取得する
-- front matterはYAML形式で記述されている前提
-- front matterのため最初に見つかった部分のみを取得する
-- 下記の形式で取得される前提となっている。front matterの中は複数行に渡ることがある。
--
-- ```txt
-- path/to/file1.md
-- ---
-- title: hoge
-- description: fuga
-- ---
-- path/to/file2.md
-- ---
-- title: geho
-- description: gafu
-- ---
-- ```
--
-- ### pathを追加して複数ファイルのfront matterを結合したyamlへ変換
--
-- 次にjqで全体がyaml形式になるように文字列を修正する
-- 下記のような形式になることを想定している
--
-- ```yaml
-- - path/to/file1.md
--   title: hoge
--   description: fuga
-- - path/to/file2.md
--   title: geho
--   description: gafu
-- ```
--
-- ### yamlをjson linesへ変換
--
-- 最後にyqでyaml形式をパースして必要なデータを取得しjson形式で出力する
-- 出力結果は、json lines形式となる。ただし、 `| @json` で出力しているので改行はない。
-- `-o json` 形式の場合、整形して出力することになり `vim.json.decode` で読み込むことができない。
--
-- ```jsonl
-- [
--   {"path": "path1", "title": "title1"},
--   {"path": "path2", "title": "title2"},
-- ]
-- ```
local function getFrontMatter(select_query)
	local command = [[
rg --json --multiline --multiline-dotall --max-count=1 --color=never --no-line-number --heading '^---\n(.*?)^(---)' '.' |
  jq -r 'select(.type == "match") | {path: .data.path.text, text: .data.lines.text | split("\n") | .[1:-2] | join("\n  ")} | "- path: \(.path)\n  \(.text)"' |
  yq -p yaml]] .. " '" .. select_query .. " | @json'"
	local data = vim.fn.system(command)
	local metadata_table = vim.json.decode(data)

	return metadata_table
end

-- snacks.nvimを利用したpicker設定
function M.snacksPicker(opts)
	local local_opts = opts or {}
	local select_query = local_opts.select_query or "."

	local finder = function()
		local front_matter_table = getFrontMatter(select_query)

		local items = {} ---@type snacks.picker.Item[]
		for i, fm in ipairs(front_matter_table) do
			---@type snacks.picker.Item
			local item = {
				idx = i,
				score = 0,
				text = fm.title,
				file = fm.path,
				filename = vim.fn.fnamemodify(fm.path, ":t"),
			}
			table.insert(items, item)
		end
		return items
	end

	require("snacks").picker({
		finder = finder,
		format = "text",
	})
end

-- 基本となる処理の設定
function M.setup()
	-- キーマッピング
	local set = vim.keymap.set
	set("n", "<Leader>Fc", function()
		vim.ui.input({ prompt = "Category: " }, function(category)
			require("front-matter-searcher").frontMatterPicker({
				select_query = 'select(.categories[]? == "' .. category .. '")',
			})
		end)
	end, { desc = "⭐︎FrontMatterSearcher: Search by Category." })
	set("n", "<Leader>Fg", function()
		vim.ui.input({ prompt = "Tag: " }, function(tag)
			require("front-matter-searcher").frontMatterPicker({
				select_query = 'select(.tags[]? == "' .. tag .. '")',
			})
		end)
	end, { desc = "⭐︎FrontMatterSearcher: Search by tag." })
	set("n", "<Leader>Ft", function()
		require("front-matter-searcher").frontMatterPicker()
	end, { desc = "⭐︎FrontMatterSearcher: Search by title." })
end

return M
