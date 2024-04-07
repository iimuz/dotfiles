-- neovim/nvim-lspconfig
-- see: <https://github.com/neovim/nvim-lspconfig>
--
-- nvim lspのconfig集

return {
  "neovim/nvim-lspconfig",
  cond = condition,
  event = {
    -- バッファを開くときに読み込み
    "BufReadPre",
    "BufNewFile",
  },
  config = function()
    -- ruffとpyrightなどを併用する場合
    -- see: <https://github.com/astral-sh/ruff-lsp?tab=readme-ov-file#example-neovim>
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
  end,
}
