-- Marksman LSP設定
-- see: https://github.com/artempyanykh/marksman
--
-- Marksmanは .marksman.toml で設定を行う
-- プロジェクトルートに.marksman.tomlを配置することでプロジェクト固有の設定が可能

---@type vim.lsp.Config
return {
	-- .marksman.tomlまたは.gitディレクトリをルートマーカーとして使用
	root_markers = { ".marksman.toml", ".git" },
}
