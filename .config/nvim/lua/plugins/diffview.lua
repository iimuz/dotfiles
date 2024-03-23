-- diffview.nvim
-- see: <https://github.com/sindrets/diffview.nvim>
--
-- gitの差分表示

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
  "sindrets/diffview.nvim",
  cond = condition,
  event = { "VimEnter" },
  -- cmd = { "DiffviewOpen" },
  config = function()
    require("diffview").setup({})

    local set = vim.keymap.set
    -- Telescope用検索コマンド
    -- PR Review用に分岐元との差分を表示
    -- see: <https://github.com/sindrets/diffview.nvim/blob/main/USAGE.md>
    set(
      "n",
      "<Plug>(diffview.open_for_pr)",
      -- diffviewopenを行うときにtab名を"hoge"に指定する
      "<cmd>DiffviewOpen origin/HEAD...HEAD --imply-local --tabname=hoge<CR>",
      { desc = "⭐︎Diffview: Open diff view for PR." }
    )
    set(
      "n",
      "<Plug>(diffview.open_for_large_pr)",
      "<cmd>DiffviewFileHistory --range=origin/HEAD...HEAD --right-only --no-merges<CR>",
      { desc = "Diffview: Open diff view for large PR." }
    )

    set(
      "n",
      "<Plug>(diffview.show_file_diff)",
      "<cmd>DiffviewFileHistory %<CR>",
      { desc = "Diffview: Open file history." }
    )

  end,
}
