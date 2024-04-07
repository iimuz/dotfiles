-- kevinhwang91/nvim-bqf
-- see: <https://github.com/kevinhwang91/nvim-bqf>
--
-- Better quickfix window

-- VSCodeから利用する場合は無効化
local condition = vim.g.vscode == nil

return {
  "kevinhwang91/nvim-bqf",
  cond = condition,
  ft = "qf", -- Quickfixをを開いたときに有効化
  dependencies = {
    -- quickfix中でzfでfzfによる絞り込みに利用。別途fzfはインストールする必要がある。
    "junegunn/fzf",
  },
  config = function()
    require("bqf").setup {}
  end,
}
