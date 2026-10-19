-- stevearc/conform.nvim
-- see: <https://github.com/stevearc/conform.nvim>
--
-- formatterの管理
-- 設定の参考例
-- - <https://github.com/josean-dev/dev-environment-files/blob/01d6e00c681c180f302885774add1537030ebb43/.config/nvim/lua/josean/plugins/formatting.lua>

return {
	"stevearc/conform.nvim",
	event = {
		-- バッファを読み込んだときに有効化
		"BufReadPre",
		"BufNewFile",
	},
	config = function(_, opts)
		local conform = require("conform")

		-- ファイルタイプごとのformatterの設定
		-- 利用するformatterはmasonで管理
		opts = {
			formatters_by_ft = {
				bash = { "shfmt" },
				css = { "prettier" },
				html = { "prettier" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				json = { "prettier" },
				lua = { "stylua" },
				markdown = { "prettier" },
				python = function(bufnr)
					local conform = require("conform")
					if conform.get_formatter_info("ruff_format", bufnr).available then
						-- ruff_fixまで実施しないとimportの修正が行われない
						return { "ruff_format", "ruff_fix" }
					else
						return { "isort", "black" }
					end
				end,
				rust = { "rustfmt", lsp_format = "fallback" },
				sh = { "shfmt" },
				-- solidity pluginが必要
				-- `npm install --save-dev prettier prettier-plugin-solidity`
				-- インストール後に以下の設定を.prettierrcなどに設定する。
				-- <https://github.com/prettier-solidity/prettier-plugin-solidity?tab=readme-ov-file#configuration-file>
				solidity = { "prettier" },
				sql = { "sqruff" },
				toml = { "taplo" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				typespec = { "typespec" },
				yaml = { "prettier" },
				zsh = { "shfmt" },
			},
			formatters = {
				-- prettier では複数の parser があるため、 filetype に応じて parser を切り替える設定を追加する。
				-- ただし、基本的にはファイル拡張子から判定する。
				-- ファイル拡張子から判断できないファイルに対して format したくなるケースのみ記載する。
				prettier = {
					prepend_args = function(self, ctx)
						local parser_map = {
							markdown = "markdown",
							json = "json",
							yaml = "yaml",
						}
						local parser = parser_map[vim.bo[ctx.buf].filetype]
						if parser then
							return { "--parser", parser }
						end
						return {}
					end,
				},
			},
		}
		conform.setup(opts)
	end,
	keys = {
		{
			"<Leader>Cf",
			function(opts)
				opts = vim.tbl_extend("keep", opts or {}, { lsp_format = "fallback", async = false, timeout_ms = 1000 })
				require("conform").format(opts)
			end,
			desc = "⭐︎Conform: Format file or range.",
		},
		{ "<Leader>Ci", "<cmd>ConformInfo<CR>", desc = "⭐︎Conform: Show information." },
		{
			"<Leader>Cs",
			function()
				vim.ui.input({ prompt = "Formatter: " }, function(formatter)
					if formatter == nil or formatter == "" then
						return
					end
					require("conform").format({ formatters = { formatter } })
				end)
			end,
			desc = "⭐︎Conform: Specific formatter.",
		},
	},
}
