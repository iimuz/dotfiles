-- git pluginの設定
-- see: <https://github.com/dinhhuy258/git.nvim>

-- vscodeから呼び出されているときは利用しない
local condition = vim.g.vscode ~= nil

retrun {
  "dinhhuy258/git.nvim",
  cond = condition,
  config = function() require("git").setup() end,
}

