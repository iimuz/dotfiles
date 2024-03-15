-- mason-lspconfigの設定
-- see: <https://github.com/williamboman/mason-lspconfig.nvim>

require("mason-lspconfig").setup {
  -- よく使うLSPはインストールしておく
  ensure_installed = {
    "dprint",  -- Markdown, json, toml formatter
    "marksman",  -- Markdown LSP
  },
}
require("mason-lspconfig").setup_handlers {
  function(server_name)
    require("lspconfig")[server_name].setup {}
  end,
}

