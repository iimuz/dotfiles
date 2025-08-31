-- Solidityの設定

return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				-- solidity pluginが必要
				-- `npm install --save-dev prettier prettier-plugin-solidity`
				-- インストール後に以下の設定を.prettierrcなどに設定する。
				-- <https://github.com/prettier-solidity/prettier-plugin-solidity?tab=readme-ov-file#configuration-file>
				solidity = { "prettier" },
			},
		},
	},
}
