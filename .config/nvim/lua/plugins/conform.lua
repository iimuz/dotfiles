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
	}, -- to disable, comment this out
	opts = {},
	config = function()
		local conform = require("conform")

		-- ファイルタイプごとのformatterの設定
		-- 利用するformatterはmasonで管理
		conform.setup({
			formatters_by_ft = {
				css = { "prettier" },
				html = { "prettier" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				json = { "prettier" },
				lua = { "stylua" },
				markdown = { "prettier" },
				python = function(bufnr)
					if conform.get_formatter_info("ruff_format", bufnr).available then
						-- ruff_fixまで実施しないとimportの修正が行われない
						return { "ruff_format", "ruff_fix" }
					else
						return { "isort", "black" }
					end
				end,
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				yaml = { "prettier" },
			},
			format_on_save = function(bufnr)
				-- Disable with a global or buffer-local variable
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return { lsp_fallback = true, async = false, timeout_ms = 1000 }
			end,
		})

		local format_func = function(opts)
			opts = vim.tbl_extend("keep", opts or {}, { lsp_fallback = true, async = false, timeout_ms = 1000 })
			conform.format(opts)
		end
		-- auto-saveプラグインから保存するときに自動でformatするための処理
		local augroup = vim.api.nvim_create_augroup("comform-auto-save", { clear = true })
		vim.api.nvim_create_autocmd({ "User" }, {
			group = augroup,
			pattern = { "AutoSaveWritePre" },
			callback = function()
				-- Disable with a global or buffer-local variable
				if vim.g.disable_autoformat then
					return
				end

				format_func()
			end,
		})
		-- ショートカットキーの登録
		vim.keymap.set({ "n", "v" }, "<Plug>(conform.format)", function()
			format_func()
		end, { desc = "⭐︎Conform: Format file or range (in visual mode)" })
		vim.keymap.set(
			"n",
			"<Plug>(conform.info)",
			"<cmd>ConformInfo<CR>",
			{ desc = "⭐︎Conform: Show information." }
		)
		vim.keymap.set({ "n", "v" }, "<Plug>(conform.format_using_specific)", function()
			vim.ui.input({ prompt = "Formatter: " }, function(formatter)
				format_func({ formatters = { formatter } })
			end)
		end, { desc = "⭐︎Conform: Format file or range (in visual mode) using specific formatter." })
		vim.keymap.set("n", "<Plug>(conform.disable)", function()
			vim.g.disable_autoformat = true
		end, { desc = "⭐︎Conform: Disable auto format." })
		vim.keymap.set("n", "<Plug>(conform.enable)", function()
			vim.g.disable_autoformat = false
		end, { desc = "⭐︎Conform: Enable auto format." })
		vim.keymap.set("n", "<Plug>(conform.buff.disable)", function()
			vim.b.disable_autoformat = true
		end, { desc = "Conform: Disable auto format for this buffer." })
		vim.keymap.set("n", "<Plug>(conform.buff.enable)", function()
			vim.g.disable_autoformat = false
		end, { desc = "Conform: Enable auto format for this buffer." })
	end,
}
