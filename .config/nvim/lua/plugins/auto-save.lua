-- pocco81/auto-save.nvim
-- see: <https://github.com/pocco81/auto-save.nvim>
--
-- ファイルの自動保存を実現する

-- VSCodeから起動した場合は無効化する
local condition = vim.g.vscode == nil

return {
  "pocco81/auto-save.nvim",
  cond = condition,
  config = function()
    require("auto-save").setup(
      {
        -- 設定例としては下記を参考にしている
        -- see: <https://zenn.dev/kenkenlysh/articles/6c93a4dbfeb2e2>
        trigger_evnets = {
          -- "InsertLeave",  -- 文字入力の完了では保存しない
          "BufLeave",
          "FocusLost",
        },
      }
    )
  end,
}
