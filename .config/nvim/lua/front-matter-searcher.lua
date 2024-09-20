-- front matterを利用した検索コマンド
--
-- Telescopeに依存している。

local M = {}

-- VSCodeから利用する場合は無効化
if vim.g.vscode ~= nil then
	function M.setup() end
	return M
end

local pickers = require("telescope.pickers") -- picker 作成用の API
local finders = require("telescope.finders") -- finder 作成用の API
local conf = require("telescope.config").values -- ユーザーの init.lua を反映した設定内容
local entry_display = require("telescope.pickers.entry_display")

-- rgでfront matterを取得して、yqでJSONに変換して返す
local function getFrontMatter(select_query)
	if select_query ~= "" then
		select_query = select_query .. " |"
	end

	-- "---"で囲まれた部分をfront matterとして取得する
	-- front matterはYAML形式で記述されている前提
	-- front matterのため最初に見つかった部分のみを取得する
	-- 下記の形式で取得される前提となっている。front matterの中は複数行に渡ることがある。
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
	local data = vim.fn.system(
		"rg --multiline --multiline-dotall --max-count=1 --color=never --no-line-number --heading '^---\n(.*?)^---' '.'"
	)

	-- 全体がyaml形式になるように文字列を修正する
	-- 下記のような形式になることを想定している
	-- ```yaml
	-- - path/to/file1.md
	--   title: hoge
	--   description: fuga
	-- - path/to/file2.md
	--   title: geho
	--   description: gafu
	-- ```
	local data_lines = {}
	for line in string.gmatch(data, "[^\r\n]+") do
		if line ~= "---" then
			if line:sub(1, 1) == "." then
				data_lines[#data_lines + 1] = "- filepath: " .. line
			else
				data_lines[#data_lines + 1] = "  " .. line
			end
		end
	end
	local data_yml = table.concat(data_lines, "\n")

	-- yqに渡すために一度、一時ファイルに書き出して実施
	-- json linesで出力する
	local tempname = vim.fn.tempname()
	local tempfile = io.open(tempname, "w")
	tempfile:write(data_yml)
	tempfile:close()
	local data_json = vim.fn.system(string.format("yq '.[] | %s @json' %s", select_query, tempname))

	-- 1行ずつjsonを変換してテーブルに変換
	local metadata_table = {}
	for line in string.gmatch(data_json, "[^\r\n]+") do
		metadata_table[#metadata_table + 1] = vim.json.decode(line)
	end

	return metadata_table
end

-- rgでfront matterを取得して、yqでJSONに変換して返す
local function getFrontMatter2(select_query)
	if select_query ~= "" then
		select_query = select_query .. " |"
	end

	-- "---"で囲まれた部分をfront matterとして取得する
	-- front matterはYAML形式で記述されている前提
	-- front matterのため最初に見つかった部分のみを取得する
	-- 下記の形式で取得される前提となっている。front matterの中は複数行に渡ることがある。
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
	local data = vim.fn.system(
		"rg --multiline --multiline-dotall --max-count=1 --color=never --no-line-number --heading '^---\n(.*?)^---' '.'"
	)

	-- 全体がyaml形式になるように文字列を修正する
	-- 下記のような形式になることを想定している
	-- ```yaml
	-- - path/to/file1.md
	--   title: hoge
	--   description: fuga
	-- - path/to/file2.md
	--   title: geho
	--   description: gafu
	-- ```
	local data_lines = {}
	for line in string.gmatch(data, "[^\r\n]+") do
		if line ~= "---" then
			if line:sub(1, 1) == "." then
				data_lines[#data_lines + 1] = "- filepath: " .. line
			else
				data_lines[#data_lines + 1] = "  " .. line
			end
		end
	end
	local data_yml = table.concat(data_lines, "\n")

	-- yqに渡すために一度、一時ファイルに書き出して実施
	-- json linesで出力する
	local tempname = vim.fn.tempname()
	local tempfile = io.open(tempname, "w")
	tempfile:write(data_yml)
	tempfile:close()
	local data_json = vim.fn.system(string.format("yq '%s .[] | @json' %s", select_query, tempname))

	-- 1行ずつjsonを変換してテーブルに変換
	local metadata_table = {}
	for line in string.gmatch(data_json, "[^\r\n]+") do
		metadata_table[#metadata_table + 1] = vim.json.decode(line)
	end

	return metadata_table
end

-- ファイルの情報を表示する
local function makeDisplay(entry)
	local metadata = entry.value
	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 40 },
			{ remaining = true },
		},
	})

	return displayer({
		metadata.title,
		{ metadata.filepath, "TelescopeResultsIdentifier" },
	})
end

-- front matterを取得してpickerを表示する
function M.frontMatterPicker(opts)
	opts = opts or {}
	local select_query = opts.select_query or ""
	pickers
		.new(opts, {
			prompt_title = "File",
			finder = finders.new_table({
				results = getFrontMatter(select_query),
				entry_maker = function(entry)
					return {
						value = entry,
						-- 検索対象として使われる文字列
						ordinal = entry.title,
						-- 画面上に表示される文字列
						display = makeDisplay,
						-- 選択したときに開くファイルのパス
						path = entry.filepath,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			previewer = conf.file_previewer(opts),
		})
		:find()
end
--
-- front matterを取得してpickerを表示する
function M.frontMatterPicker2(opts)
	opts = opts or {}
	local select_query = opts.select_query or ""
	pickers
		.new(opts, {
			prompt_title = "File",
			finder = finders.new_table({
				results = getFrontMatter2(select_query),
				entry_maker = function(entry)
					return {
						value = entry,
						-- 検索対象として使われる文字列
						ordinal = entry.title,
						-- 画面上に表示される文字列
						display = makeDisplay,
						-- 選択したときに開くファイルのパス
						path = entry.filepath,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			previewer = conf.file_previewer(opts),
		})
		:find()
end

-- 基本となる処理の設定
--
-- ショートカットキーの登録はwhich-keyで行うため何もしていない。
function M.setup() end

return M
