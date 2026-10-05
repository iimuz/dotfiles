-- スペルチェッカー (cspell, typos) の切り替え
--
-- cspell は設定がある時だけ動かす。設定の無い cspell は辞書に無い識別子を大量に指摘するため。
-- typos は誤検知が少ないので、cspell の設定だけがある場合を除いて動かす。

local M = {}

M.cspell_files = {
	"cspell.json",
	".cspell.json",
	"cSpell.json",
	".cSpell.json",
	"cspell.config.js",
	"cspell.config.cjs",
	"cspell.config.mjs",
	"cspell.config.json",
	"cspell.config.yaml",
	"cspell.config.yml",
	"cspell.yaml",
	"cspell.yml",
}

M.typos_files = { "typos.toml", "_typos.toml", ".typos.toml" }

--- バッファに対して動かす nvim-lint の linter 名を返す
---@param source integer|string バッファ番号かファイルパス
---@return string[]
function M.linters(source)
	local has_cspell = vim.fs.root(source, M.cspell_files) ~= nil
	local has_typos = vim.fs.root(source, M.typos_files) ~= nil
	if has_cspell and has_typos then
		return { "cspell", "typos" }
	end
	if has_cspell then
		return { "cspell" }
	end
	return { "typos" }
end

return M
