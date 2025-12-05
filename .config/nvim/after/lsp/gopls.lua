-- GoのLSP設定
-- tcd等でproject rootを適切に検出するための設定

---@type vim.lsp.Config
return {
	root_markers = { "go.work", "go.mod", ".git" },
	capabilities = {
		workspace = {
			didChangeWatchedFiles = {
				dynamicRegistration = false,
			},
		},
	},
	settings = {
		gopls = {
			-- 不要なディレクトリを除外
			directoryFilters = { "-**/node_modules", "-**/vendor", "-**/.git" },
			-- 閉じたファイルのメモリを解放（パフォーマンス向上）
			memoryMode = "DegradeClosed",
		},
	},
}
