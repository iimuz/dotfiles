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
    "BufNewFile"
  }, -- to disable, comment this out
  opts = {},
  config = function()
    local conform = require("conform")

    -- dprintが有効な場合のみdprintを返し、それ以外はformattersを返す
    -- dprintが失敗すると`formatters_by_ft = { markdown = {{ "dprint", "prettier" }}`が正しく動作しない
    local dprint_or_others = function(bufnr, formatters)
      local dprint_available = require("conform").get_formatter_info("dprint", bufnr).available
      -- `dprint.json`がneovimを開いているディレクトリに存在するか確認した結果をbooleanでflag変数に格納
      local has_dprint_json = vim.fn.filereadable("dprint.json") == 1
      if dprint_available and has_dprint_json then
        return { "dprint" }
      end

      return formatters
    end

    -- ファイルタイプごとのformatterの設定
    -- 利用するformatterはmasonで管理
    conform.setup({
      formatters_by_ft = {
        css = { "prettier" },
        html = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = function(bufnr) return dprint_or_others(bufnr, { "prettier" }) end,
        lua = { "stylua" },
        markdown = function(bufnr) return dprint_or_others(bufnr, { "prettier" }) end,
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
