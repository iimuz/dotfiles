-- GoのLSP設定
-- tcd等でproject rootを適切に検出するための設定

---@type vim.lsp.Config
return {
	root_markers = { "go.work", "go.mod", ".git" },
}
