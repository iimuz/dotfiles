--- Builtin LSPの設定

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ctx)
		-- see: <https://github.com/neovim/nvim-lspconfig?tab=readme-ov-file#suggested-configuration>
		local set = vim.keymap.set
		set("n", "gD", vim.lsp.buf.declaration, {
			buffer = ctx.buff,
			desc = "⭐︎LSP: Go to declaration.",
		})
		set("n", "gd", vim.lsp.buf.definition, {
			buffer = ctx.buff,
			desc = "⭐︎LSP: Go to definition.",
		})
		set("n", "K", vim.lsp.buf.hover, {
			buffer = true,
			desc = "⭐︎LSP: Show hover.",
		})
		set("n", "gi", vim.lsp.buf.implementation, {
			buffer = true,
			desc = "⭐︎LSP: Go to implementation.",
		})
		set("n", "<C-k>", vim.lsp.buf.signature_help, {
			buffer = true,
			desc = "⭐︎LSP: Show signature help.",
		})
		set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, {
			buffer = true,
			desc = "LSP: Add workspace folder.",
		})
		set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, {
			buffer = true,
			desc = "LSP: Remove workspace folder.",
		})
		set("n", "<space>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, {
			buffer = true,
			desc = "LSP: List workspace folders.",
		})
		set("n", "<space>D", vim.lsp.buf.type_definition, {
			buffer = true,
			desc = "⭐︎LSP: Type definition.",
		})
		set("n", "<space>rn", vim.lsp.buf.rename, {
			buffer = true,
			desc = "⭐︎LSP: Rename.",
		})
		set("n", "<space>ca", vim.lsp.buf.code_action, {
			buffer = true,
			desc = "⭐︎LSP: Code action.",
		})
		set("n", "gr", vim.lsp.buf.references, {
			buffer = true,
			desc = "⭐︎LSP: Show references.",
		})
		set("n", "<space>e", vim.diagnostic.open_float, {
			buffer = true,
			desc = "⭐︎LSP: Show line diagnostics.",
		})
		set("n", "[d", vim.diagnostic.goto_prev, {
			buffer = true,
			desc = "⭐︎LSP: Go to previous diagnostics.",
		})
		set("n", "]d", vim.diagnostic.goto_next, {
			buffer = true,
			desc = "⭐︎LSP: Go to next diagnostics.",
		})
		set("n", "<space>q", vim.diagnostic.setloclist, {
			buffer = true,
			desc = "⭐︎LSP: Set loclist diagnostics.",
		})
		set("n", "<space>f", function()
			vim.lsp.buf.format({ async = true })
		end, {
			buffer = true,
			desc = "⭐︎LSP: Formatting.",
		})
	end,
})

-- Telescopeでのコマンド検索用
vim.keymap.set("n", "<Plug>lsp.info", "<cmd>LspInfo<CR>", { desc = "LSP: Show lsp info." })
