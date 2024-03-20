-- stevearc/aerial
-- see: <https://github.com/stevearc/aerial.nvim>
--
-- Outline表示

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

-- 起動用のキーマッピング
vim.keymap.set(
  "n",
  "<Plug>aerial.load",
  "<cmd>AerialNavOpen<CR>",
  {desc = "⭐︎Aerial: Load aerial(Outline plugin)."}
)

return {
  'stevearc/aerial.nvim',
  cond = condition,
  cmd = {
    "AerialToggle",
    "AerialOpen",
    "AerialNavOpen",
  },
  dependencies = {
     "nvim-treesitter/nvim-treesitter",
     "nvim-tree/nvim-web-devicons"
  },
  opts = {},
  config = function()
    local set = vim.keymap.set
    require("aerial").setup({
      -- Priority list of preferred backends for aerial.
      -- This can be a filetype map (see :help aerial-filetype-map)
      backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },
      -- optionally use on_attach to set keymaps when aerial has attached to a buffer
      on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
        set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
      end,
    })
    -- Telescope用検索コマンド
    set(
      "n",
      "<Plug>aerial.toggl",
      "<cmd>AerialToggle!<CR>",
      {desc = "Aerial: Toggle outline window."}
    )
    set(
      "n",
      "<Plug>aerial.open",
      "<cmd>AerialOpen!<CR>",
      {desc = "Aerial: Open outline window."}
    )
    set(
      "n",
      "<Plug>aerial.close",
      "<cmd>AerialClose<CR>",
      {desc = "Aerial: Close outline window."}
    )
    set(
      "n",
      "<Plug>aerial.nav.open",
      "<cmd>AerialNavOpen<CR>",
      {desc = "⭐︎Aerial: Open outline navigation."}
    )
    set(
      "n",
      "<Plug>aerial.nav.close",
      "<cmd>AerialNavClose<CR>",
      {desc = "Aerial: Close outline navigation."}
    )

    -- Telescope拡張
    require("telescope").load_extension("aerial")
    set(
      "n",
      "<Plug>aerial.telescope",
      "<cmd>Telescope aerial<CR>",
      {desc = "Aerial: Show outline using Telescope"}
    )
  end,
}
