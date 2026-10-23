-- Rust (rust-analyzer) のLSP設定
--
-- see: https://rust-analyzer.github.io/book/configuration.html

---@type vim.lsp.Config
return {
	root_markers = { "Cargo.toml", "rust-project.json", ".git" },
	settings = {
		["rust-analyzer"] = {
			-- 保存時に clippy を実行（check より厳密な静的解析）
			check = {
				command = "clippy",
			},
		},
	},
}
