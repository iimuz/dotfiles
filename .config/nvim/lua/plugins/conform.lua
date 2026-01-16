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

		-- format_on_saveの共通実装
		local format_on_save_fn = function(bufnr)
			-- Disable with a global or buffer-local variable
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return { lsp_fallback = true, async = false, timeout_ms = 1000 }
		end

		-- ファイルタイプごとのformatterの設定
		-- 利用するformatterはmasonで管理
		opts = {
			formatters_by_ft = {
				bash = { "shfmt" },
				css = { "prettier" },
				html = { "prettier" },
				http = { "kulala-fmt" },
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
				rest = { "kulala-fmt" },
				rust = { "rust_analyzer" },
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
				typespec = { "tsp" },
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
			format_on_save = format_on_save_fn,
		}
		conform.setup(opts)

		-- auto-saveプラグインから保存するときに自動でformatするための処理
		local augroup = vim.api.nvim_create_augroup("comform-auto-save", { clear = true })
		vim.api.nvim_create_autocmd({ "User" }, {
			group = augroup,
			pattern = { "AutoSaveWritePre" },
			callback = function()
				local bufnr = vim.api.nvim_get_current_buf()
				local format_opts = format_on_save_fn(bufnr)
				if format_opts then
					conform.format(format_opts)
				end
			end,
		})
	end,
	keys = {
		{
			"<Leader>Cb",
			function()
				vim.b.disable_autoformat = true
			end,
			desc = "Conform: Disable for this buffer.",
		},
		{
			"<Leader>CB",
			function()
				vim.b.disable_autoformat = false
			end,
			desc = "⭐︎Conform: Enable for this buffer.",
		},
		{
			"<Leader>Cf",
			function(opts)
				opts = vim.tbl_extend("keep", opts or {}, { lsp_fallback = true, async = false, timeout_ms = 1000 })
				require("conform").format(opts)
			end,
			desc = "⭐︎Conform: Format file or range.",
		},
		{
			"<Leader>Cg",
			function()
				vim.g.disable_autoformat = false
			end,
			desc = "Conform: Enable",
		},
		{
			"<Leader>CG",
			function()
				vim.g.disable_autoformat = true
			end,
			desc = "Conform: Disable.",
		},
		{ "<Leader>Ci", "<cmd>ConformInfo<CR>", desc = "⭐︎Conform: Show information." },
		{
			"<Leader>Cs",
			function()
				vim.ui.input({ prompt = "Formatter: " }, function(formatter)
					format({ formatters = { formatter } })
				end)
			end,
			desc = "⭐︎Conform: Specific formatter.",
		},
	},
}
