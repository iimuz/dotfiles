--- Builtin LSPの設定

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ctx)
		-- see: <https://github.com/neovim/nvim-lspconfig?tab=readme-ov-file#suggested-configuration>
		require("which-key").register({
			l = {
				l = {
					name = "LSP",
					a = { vim.lsp.buf.code_action, "⭐︎LSP: Code action." },
					d = { vim.lsp.buf.definition, "⭐︎LSP: Go to definition." },
					D = { vim.lsp.buf.declaration, "⭐︎LSP: Go to declaration." },
					e = {
						name = "Diagnostic",
						o = { vim.diagnostic.open_float, "⭐︎LSP: Show line diagnostics." },
						p = { vim.diagnostic.goto_prev, "⭐︎LSP: Go to previous diagnostics." },
						n = { vim.diagnostic.goto_next, "⭐︎LSP: Go to next diagnostics." },
						l = { vim.diagnostic.setloclist, "⭐︎LSP: Set loclist diagnostics." },
					},
					f = {
						function()
							vim.lsp.buf.format({ async = true })
						end,
						"⭐︎LSP: Formatting.",
					},
					i = { vim.lsp.buf.implementation, "⭐︎LSP: Go to implementation." },
					k = { vim.lsp.buf.signature_help, "⭐︎LSP: Show signature help." },
					K = { vim.lsp.buf.hover, "⭐︎LSP: Show hover." },
					n = { vim.lsp.buf.rename, "⭐︎LSP: Rename." },
					r = { vim.lsp.buf.references, "⭐︎LSP: Show references." },
					s = { "<cmd>LspInfo<CR>", "⭐︎LSP: Show lsp info." },
					t = { vim.lsp.buf.type_definition, "⭐︎LSP: Type definition." },
					w = {
						name = "workspace",
						a = { vim.lsp.buf.add_workspace_folder, "LSP: Add workspace folder." },
						r = { vim.lsp.buf.remove_workspace_folder, "LSP: Remove workspace folder." },
						l = { vim.lsp.buf.list_workspace_folders, "LSP: List workspace folders." },
					},
				},
			},
		}, {
			prefix = "<leader>",
			buffer = ctx.buff,
		})
	end,
})
