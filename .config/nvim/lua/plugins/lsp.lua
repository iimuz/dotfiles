-- LSP設定
-- 複数のプラグインが依存するためLSP関連をまとめて記述

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

-- Neovim builtin LSP
return {
  -- Builtin LSPのconfiguration
  {
    "neovim/nvim-lspconfig",
    cond = condition,
  },
  -- LSP manager
  {
    "williamboman/mason.nvim",
    cond = condition,
    config = function()
      require("mason").setup()
    end,
  },
  {
    -- mason-lspconfigの設定
    -- see: <https://github.com/williamboman/mason-lspconfig.nvim>
    "williamboman/mason-lspconfig.nvim",
    cond = condition,
    config = function()
      require("mason-lspconfig").setup {
        -- よく使うLSPはインストールしておく
        ensure_installed = {
          "dprint",  -- Markdown, json, toml formatter
          "marksman",  -- Markdown LSP
        },
      }

      -- Setup lspconfig to nvim-cmp
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      require("mason-lspconfig").setup_handlers {
        function(server_name)
          require("lspconfig")[server_name].setup {
            capabilities = capabilities,
          }
        end,
      }
    end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",  -- capabilityを設定
    },
  },
}

