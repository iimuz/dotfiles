-- hrsh7th/nvim-cmp
-- see: <>
--
-- Completion

local condition = vim.g.vscode == nil

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  cond = condition,
  dependencies = {
    { "hrsh7th/cmp-buffer" },  -- 開いているバッファからのキーワード補完
    { "hrsh7th/cmp-nvim-lsp" },  -- LSPからの補完
    { "hrsh7th/cmp-path" },  -- パス補完
    -- { "petertriho/cmp-git" },  -- git issueなどの補完
    -- { "hrsh7th/cmp-emoji" },
    -- { "hrsh7th/cmp-vsnip" },
    -- { "onsails/lspkind.nvim" },
  },
  config = function()
    local cmp = require("cmp")
    cmp.setup {
      mapping = cmp.mapping.preset.insert({
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-u>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
      }),
      sources = cmp.config.sources(
        {
          -- 開いているバッファからのキーワード補完
          -- see: <https://github.com/hrsh7th/cmp-buffer>
          {name = "buffer"},
          -- LSPからの補完
          -- see: <https://github.com/hrsh7th/cmp-nvim-lsp>
          {name = "nvim_lsp"},
          -- パス補完
          -- see: <https://github.com/hrsh7th/cmp-path>
          {name = "path"},
          -- git issueなどの補完
          -- see: <https://github.com/petertriho/cmp-git>
          {name = "git" },
        }
      ),
    }

    -- cmp.setup.cmdline({ '/', '?' }, {
    --   mapping = cmp.mapping.preset.cmdline(),
    --   sources = {
    --     { name = 'buffer' }
    --   }
    -- })
  end,
}

