-- ファイルの自動保存を行う

-- 自動保存関数
local function autoSave()
  local buf = vim.api.nvim_get_current_buf()

  -- 無名ファイルの場合は自動保存の対象外
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then return end
  -- 編集不可のファイルは保存の対象外
  local modifiable = vim.api.nvim_buf_get_option(buf, "modifiable")
  if not modifiable then return end

  -- 保存の実行
  vim.api.nvim_buf_call(
    buf,
    function()
      vim.cmd("silent! write")
    end
  )
end

-- 自動保存機能をeventに紐付け
vim.api.nvim_create_autocmd(
  {
    "BufLeave", -- バッファを離れた際は自動保存
    -- tmuxを利用する場合に"FocusLost"でファイルを保存するためには`set -g focus-events on`にしておく必要がある。
    -- see: <https://qiita.com/sijiaoh/items/874cd77e083b8ab05151>
    "FocusLost",
  },
  {
    pattern = { "*" },
    callback = autoSave,
  }
)
