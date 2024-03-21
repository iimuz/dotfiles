-- stevearc/conform.nvim
-- see: <>
--
-- formatterの管理
-- 設定の参考例
-- - <https://github.com/josean-dev/dev-environment-files/blob/01d6e00c681c180f302885774add1537030ebb43/.config/nvim/lua/josean/plugins/formatting.lua>

return {
  "stevearc/conform.nvim",
  event = {
    -- バッファを読み込んだときに有効化
    "BufReadPre",
    "BufNewFile"
  }, -- to disable, comment this out
  config = function()
    local conform = require("conform")

    -- ファイルタイプごとのformatterの設定
    conform.setup({
      formatters_by_ft = {
        css = { "prettier" },
        html = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { { "dprint", "prettier" } },
        lua = { "stylua" },
        markdown = { { "dprint", "prettier" } },
        python = { "ruff" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        yaml = { "prettier" },
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      },
    })

    -- ショートカットキーの登録
    vim.keymap.set(
      { "n", "v" },
      "<Plug>conform.format",
      function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end, { desc = "⭐︎Conform: Format file or range (in visual mode)" })
  end,
}
