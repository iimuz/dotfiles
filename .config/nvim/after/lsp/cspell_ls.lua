-- CSpell LSP設定
--
-- see: <https://github.com/vlabo/cspell-lsp>

---@type vim.lsp.Config
return {
	-- 既定の root_markers は .git を含み、cspell の設定が無いリポジトリでも attach するため、
	-- cspell の設定ファイルだけに絞る
	root_markers = require("spell-check").cspell_files,
}
