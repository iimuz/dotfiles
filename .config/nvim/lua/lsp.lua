--- Builtin LSPの設定

vim.api.nvim_create_autocmd(
  "LspAttach",
  {
    callback = function(ctx)
      local set = vim.keymap.set
      set(
        "n",
        "gD",
        "<cmd>lua vim.lsp.buf.declaration()<CR>",
        {
          buffer = true,
          desc = "⭐︎LSP: Go to declaration.",
        }
      )
      set(
        "n",
        "gd",
        "<cmd>lua vim.lsp.buf.definition()<CR>",
        {
          buffer = true,
          desc = "⭐︎LSP: Go to definition.",
        }
      )
      set(
        "n",
        "K",
        "<cmd>lua vim.lsp.buf.hover()<CR>",
        {
          buffer = true,
          desc = "⭐︎LSP: Show hover.",
        }
      )
      set(
        "n",
        "gi",
        "<cmd>lua vim.lsp.buf.implementation()<CR>",
        {
          buffer = true,
          desc = "⭐︎LSP: Go to implementation.",
        }
      )
      set(
        "n",
        "<C-k>",
        "<cmd>lua vim.lsp.buf.signature_help()<CR>",
        {
          buffer = true,
          desc = "⭐︎LSP: Show signature help.",
        }
      )
      set(
        "n",
        "<space>wa",
        "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>",
        {
          buffer = true,
          desc = "LSP: Add workspace folder.",
        }
      )
      set(
        "n",
        "<space>wr",
        "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>",
        {
          buffer = true,
          desc = "LSP: Remove workspace folder.",
        }
      )
      set(
        "n",
        "<space>wl",
        "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
        {
          buffer = true,
          desc = "LSP: List workspace folders.",
        }
      )
      set(
        "n",
        "<space>D",
        "<cmd>lua vim.lsp.buf.type_definition()<CR>",
        {
          buffer = true,
          desc = "⭐︎LSP: Type definition.",
        }
      )
      set(
        "n",
        "<space>rn",
        "<cmd>lua vim.lsp.buf.rename()<CR>",
        {
          buffer = true,
          desc = "⭐︎LSP: Rename.",
        }
      )
      set(
        "n",
        "<space>ca",
        "<cmd>lua vim.lsp.buf.code_action()<CR>",
        {
          buffer = true,
          desc = "⭐︎LSP: Code action.",
        }
      )
      set(
        "n",
        "gr",
        "<cmd>lua vim.lsp.buf.references()<CR>",
        {
          buffer = true,
          desc = "⭐︎LSP: Show references.",
        }
      )
      set(
        "n",
        "<space>e",
        "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>",
        {
          buffer = true,
          desc = "⭐︎LSP: Show line diagnostics.",
        }
      )
      set(
        "n",
        "[d",
        "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>",
        {
          buffer = true,
          desc = "⭐︎LSP: Go to previous diagnostics.",
        }
      )
      set(
        "n",
        "]d",
        "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>",
        {
          buffer = true,
          desc = "⭐︎LSP: Go to next diagnostics.",
        }
      )
      set(
        "n",
        "<space>q",
        "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>",
        {
          buffer = true,
          desc = "LSP: Set loclist diagnostics.",
        }
      )
      set(
        "n",
        "<space>f",
        "<cmd>lua vim.lsp.buf.formatting()<CR>",
        {
          buffer = true,
          desc = "⭐︎LSP: Formatting.",
        }
      )
    end,
  }
)

