-- sqlに関連する設定を行う。
--
-- 2025-08-31:
-- dadbod一式をsnowflake接続に利用しようとしたが、接続にsnowsql(旧式)を要求したため設定をせず。
-- vscodeから利用することにする。

return {
	-- conformのformatter設定のみ追加
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				sql = { "sqruff" },
			},
		},
	},
}
