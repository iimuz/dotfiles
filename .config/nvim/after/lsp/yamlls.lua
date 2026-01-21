-- YAML Language Server設定
--
-- see: <https://github.com/redhat-developer/yaml-language-server>

---@type vim.lsp.Config
return {
	settings = {
		yaml = {
			-- バリデーション、補完、ホバー情報を有効化
			validate = true,
			completion = true,
			hover = true,

			-- フォーマット設定は Conform で行うので無効化
			format = {
				enable = false,
			},

			-- SchemaStoreから自動でスキーマを取得
			schemaStore = {
				enable = true,
				url = "https://www.schemastore.org/api/json/catalog.json",
			},
			-- 個別スキーマ指定
			schemas = {
				-- Docker Compose
				["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
					"docker-compose*.yml",
					"docker-compose*.yaml",
					"compose*.yml",
					"compose*.yaml",
				},
				-- GitHub Actions
				["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
				-- Kubernetes
				["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.29.0/all.json"] = {
					"k8s/**/*.yaml",
					"k8s/**/*.yml",
				},
			},
		},
	},
}
