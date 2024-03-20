-- LSP設定
-- 複数のプラグインが依存するためLSP関連をまとめて記述

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

-- ruffとpyrightなどを併用する場合
-- see: <https://github.com/astral-sh/ruff-lsp?tab=readme-ov-file#example-neovim>
local function lspRuffPyright()
  require("lspconfig").ruff_lsp.setup {
    init_options = {
      settings = {
        -- Any extra CLI arguments for "ruff" go here.
        args = {}
      },
    },
    on_attach = function(client, _)
      if client.name == 'ruff_lsp' then
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
      end
    end,
  }
end

-- 起動用のキーマッピング
local set = vim.keymap.set
set(
  "n",
  "<Plug>(mason.loading)",
  "<cmd>Mason<CR>",
  { desc = "⭐︎Mason: Load." }
)
set(
  "n",
  "<Plug>(mason.update)",
  "<cmd>MasonUpdate<CR>",
  { desc = "Mason: update." }
)

-- Neovim builtin LSPを利用する前提
return {
  -- Builtin LSPのconfiguration
  {
    "neovim/nvim-lspconfig",
    cond = condition,
    event = { "InsertEnter" },
    config = function()
      lspRuffPyright()
    end,
  },
  -- LSP manager - mason
  {
    "williamboman/mason.nvim",
    cond = condition,
    cmd = { "Mason" },
    config = function()
      require("mason").setup()

      -- Telescope検索用コマンドの登録
      vim.keymap.set(
        "n",
        "<Plug>(mason.ui)",
        "<cmd>Mason<CR>",
        { desc = "Mason: Show Mason UI." }
      )
      vim.keymap.set(
        "n",
        "<Plug>(mason.log)",
        "<cmd>MasonLog<CR>",
        { desc = "Mason: Show log." }
      )
    end,
  },
  -- mason-lspconfigの設定
  -- see: <https://github.com/williamboman/mason-lspconfig.nvim>
  {
    "williamboman/mason-lspconfig.nvim",
    cond = condition,
    event = { "InsertEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- capabilityを設定
    },
    config = function()
      require("mason-lspconfig").setup {
        -- よく使うLSPはインストールしておく
        ensure_installed = {
          "gopls",    -- Go lang LSP
          "marksman", -- Markdown LSP
          "pyright",  -- Python LSP
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
  },
  -- Formatter, Linter用の設定
  {
    -- see: <https://github.com/jay-babu/mason-null-ls.nvim>
    "jay-babu/mason-null-ls.nvim",
    cond = condition,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    config = function()
      local mason_null_ls = require("mason-null-ls")
      mason_null_ls.setup({
        ensure_installed = {
          -- Opt to list sources here, when available in mason.
          "dprint", -- Markdown, json, toml formatter
          "ruff",   -- Python linter, formatter
        },
        automatic_installation = true,
        handlers = {},
      })
      -- mason_null_ls.check_install(true)
    end,
  },
  {
    -- see: <https://github.com/nvimtools/none-ls.nvim>
    -- [null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim)は、
    -- 2023-08-12にArchivedされており、後継となるnone-ls.nvimを利用する
    "nvimtools/none-ls.nvim",
    cond = condition,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("null-ls").setup(
        {
          sources = {
            -- Anything not supported by mason.
          },
        }
      )
    end,
  },
}
