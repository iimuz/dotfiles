-- Markdownのリンクでbacklink, forward linkを検索する

local M = {}

-- 現在のファイル名を元にリンクしているファイルを検索し一覧を返す。
--
-- ファイルリンクは、`[hoge](filename_without_suffix)`の形式を想定
--
-- ## コマンドの実行手順
--
-- 1. rgで `[text](link)` でlinkが現在のバッファのファイル名と一致するファイルを検索
-- 1. ファイルパスで一意になるようにユニーク化
-- 1. 対象ファイルから一括でfront matterを検索
-- 1. front matterにpathを追加して複数ファイルのyaml形式に変換
-- 1. yamlをjsonに変換
-- 1. `vim.json.decode` でテーブルに変換して返す
local function readBackLinkFrontMater(select_query)
	local filename = vim.fn.expand("%:t:r")
	local command = 'rg --json --max-count=1 "\\[.*\\]\\('
		.. filename
		.. '\\)" "." |'
		.. [[jq -cr 'select(.type == "match")  | .data.path.text' |
  sort |
  uniq |
  xargs rg --json --multiline --multiline-dotall --max-count=1 --color=never --no-line-number --heading '^---\n(.*?)^(---)' |
  jq -r 'select(.type == "match") | {path: .data.path.text, text: .data.lines.text | split("\n") | .[1:-2] | join("\n  ")} | "- path: \(.path)\n  \(.text)"' |
  yq -p yaml]]
		.. " '"
		.. select_query
		.. " | @json'"
	local data = vim.fn.system(command)
	local metadata_table = vim.json.decode(data)

	return metadata_table
end

-- snacks.nvimを利用したpicker設定
function M.snacksPicker()
	local select_query = "."

	local finder = function()
		local front_matter_table = readBackLinkFrontMater(select_query)

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

-- 設定関数
function M.setup()
	-- キーマッピング
	local set = vim.keymap.set
	set("n", "<Leader>h", function()
		require("markdown-hop-links").snacksPicker()
	end, { desc = "⭐︎MarkdownHopLinks: Show backlinks." })
end

return M
