-- Markdownのリンクでbacklink, forward linkを検索する

local M = {}

-- 指定した配列から重複を排除した配列を返す
local function unique(arr)
	local unique_set = {}
	local seen = {}
	for _, v in ipairs(arr) do
		if not seen[v] then
			unique_set[#unique_set + 1] = v
			seen[v] = true
		end
	end

	return unique_set
end

-- 指定したファイルに対する参照を取得する
--
-- ファイルリンクは、`[hoge](filename_without_suffix)`の形式を想定
local function searchFilepath(filepath)
	local current_filename = vim.fn.fnamemodify(filepath, ":t:r")
	local data = vim.fn.system(
		"rg --multiline --multiline-dotall --max-count=1 --color=never --no-line-number --heading --json '"
			.. current_filename
			.. "' '.'"
	)

	local target_files = {}
	for line in string.gmatch(data, "[^\r\n]+") do
		local line_dict = vim.json.decode(line)
		-- line_dictからdata/path/textを抽出する。もし、要素がなければ何もしない
		if line_dict["data"] ~= nil then
			if line_dict["data"]["path"] ~= nil then
				if line_dict["data"]["path"]["text"] ~= nil then
					target_files[#target_files + 1] = line_dict["data"]["path"]["text"]
				end
			end
		end
	end
	unique_target_files = unique(target_files)

	return unique_target_files
end

-- backlinkを2回実施
--
-- 参考に記載中であり利用していない。
local function search2Hop(filepath)
	local first_references = searchFilepath(filepath)

	local target_files = {}
	for _, file in ipairs(first_references) do
		local second_references = searchFilepath(file)

		target_files[#target_files + 1] = file
		for _, second_file in ipairs(second_references) do
			target_files[#target_files + 1] = second_file
		end
	end
	unique_target_files = unique(target_files)

	return unique_target_files
end

-- 指定したファイルのfront matterを抽出する
--
-- front matter部分をrgで抽出して、yqでyamlをjson形式に変換してから読み込む
local function extractMetadata(filepath)
	local data = vim.fn.system(
		"rg --multiline --multiline-dotall --max-count=1 --color=never --no-line-number --heading '^---\n(.*?)^---' '"
			.. filepath
			.. "'"
	)
	local data_lines = {}
	for line in string.gmatch(data, "[^\r\n]+") do
		if line ~= "---" then
			data_lines[#data_lines + 1] = line
		end
	end
	local data_yml = table.concat(data_lines, "\n")

	local tempname = vim.fn.tempname()
	local tempfile = io.open(tempname, "w")
	tempfile:write(data_yml)
	tempfile:close()
	local data_json = vim.fn.system(string.format("yq '. | @json' %s", tempname))
	local meta = vim.json.decode(data_json)
	meta["filepath"] = filepath

	return meta
end

-- Telescope.nvimでファイルの情報を表示する
local function makeDisplay(entry)
	local entry_display = require("telescope.pickers.entry_display")

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
	local pickers = require("telescope.pickers") -- picker 作成用の API
	local finders = require("telescope.finders") -- finder 作成用の API
	local conf = require("telescope.config").values -- ユーザーの init.lua を反映した設定内容

	local files = searchFilepath(vim.fn.expand("%:p"))
	local meta = {}
	for _, file in ipairs(files) do
		meta[#meta + 1] = extractMetadata(file)
	end

	opts = opts or {}
	local select_query = opts.select_query or ""
	pickers
		.new(opts, {
			prompt_title = "File",
			finder = finders.new_table({
				results = meta,
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

-- 設定関数
--
-- ショートカットキーの登録はwhich-keyで行うため何もしていない。
function M.setup() end

return M
