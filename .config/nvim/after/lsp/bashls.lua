-- Bash LSP設定
--
-- see: <https://github.com/bash-lsp/bash-language-server>

---@type vim.lsp.Config
return {
	settings = {
		bashIde = {
			-- macOS で `file://` URLエラーが発生するため空に設定
			-- 参考: <https://github.com/bash-lsp/bash-language-server/issues/1360>
			globPattern = "",
			-- 背景解析を 50 ファイルに制限 (パフォーマンスとのバランス)
			backgroundAnalysisMaxFiles = 50,
		},
	},
}
