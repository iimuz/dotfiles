-- LSP Management and Keybindings

local M = {}

function M.setup()
	-- see: <https://github.com/neovim/nvim-lspconfig?tab=readme-ov-file#suggested-configuration>
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(ctx)
			-- キーマッピング
			local set = vim.keymap.set

			set("n", "gd", vim.lsp.buf.definition, { desc = "⭐︎LSP: Go to definition.", buffer = ctx.buf })
			set("n", "gD", vim.lsp.buf.declaration, { desc = "⭐︎LSP: Go to declaration.", buffer = ctx.buf })
			set("n", "K", vim.lsp.buf.hover, { desc = "⭐︎LSP: Show hover.", buffer = ctx.buf })
			set(
				"n",
				"[d",
				-- `vim.diagnostic.goto_next` はdeprecatedだが移行先の以下のコマンドでエラーするので暫定で戻す
				-- vim.diagnostic.jump({ count = 1, float = true }),
				vim.diagnostic.goto_next,
				{ desc = "⭐︎LSP: Go to previous diagnostics.", buffer = ctx.buf }
			)
			set(
				"n",
				"]d",
				-- `vim.diagnostic.goto_prev` はdeprecatedだが移行先の以下のコマンドでエラーするので暫定で戻す
				-- vim.diagnostic.jump({ count = -1, float = true }),
				vim.diagnostic.goto_prev,
				{ desc = "⭐︎LSP: Go to next diagnostics.", buffer = ctx.buf }
			)
			set(
				"n",
				"<C-k>",
				vim.lsp.buf.signature_help,
				{ desc = "⭐︎LSP: Show signature help.", buffer = ctx.buf }
			)
			set(
				"n",
				"<Leader>le",
				vim.diagnostic.open_float,
				{ desc = "⭐︎LSP: Show line diagnostics.", buffer = ctx.buf }
			)
			set("n", "<Leader>lf", function()
				vim.lsp.buf.format({ async = true })
			end, { desc = "⭐︎LSP: Formatting.", buffer = ctx.buf })
			set(
				"n",
				"<Leader>ll",
				vim.diagnostic.setloclist,
				{ desc = "⭐︎LSP: Set loclist diagnostics.", buffer = ctx.buf }
			)
			set("n", "<Leader>ls", "<cmd>LspRestart<CR>", { desc = "⭐︎LSP: Restart lsp.", buffer = ctx.buf })
			set("n", "<Leader>lS", "<cmd>LspInfo<CR>", { desc = "⭐︎LSP: Show lsp info.", buffer = ctx.buf })

			-- 以下のキーは既に<gr>のグループに割り当てられていたので割り当てない
			-- - gra: code action
			-- - grr: references
			-- - gri: implementation
			-- - grt: type_definition
			-- - grn: rename
			-- set("n", "gi", vim.lsp.buf.implementation, { desc = "⭐︎LSP: Go to implementation.", buffer = ctx.buf })
			-- set("n", "gr", vim.lsp.buf.references, { desc = "⭐︎LSP: Show references.", buffer = ctx.buf })
			-- set("n", "gy", vim.lsp.buf.type_definition, { desc = "⭐︎LSP: Type definition.", buffer = ctx.buf })
			-- set("n", "<Leader>la", vim.lsp.buf.code_action, { desc = "⭐︎LSP: Code action.", buffer = ctx.buf })
			-- set("n", "<Leader>ln", vim.lsp.buf.rename, { desc = "⭐︎LSP: Rename.", buffer = ctx.buf })
		end,
	})
end

return M
