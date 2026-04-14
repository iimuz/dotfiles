-- Rust (rust-analyzer) のLSP設定
--
-- see: https://rust-analyzer.github.io/book/configuration.html

---@type vim.lsp.Config
return {
	root_markers = { "Cargo.toml", "rust-project.json", ".git" },
	capabilities = {
		general = {
			-- copilot/cspell_ls (UTF-16) との不一致を解消し参照検索等を正常動作させる
			positionEncodings = { "utf-16" },
		},
	},
	settings = {
		["rust-analyzer"] = {
			-- 保存時に clippy を実行（check より厳密な静的解析）
			check = {
				command = "clippy",
			},
		},
	},
}
