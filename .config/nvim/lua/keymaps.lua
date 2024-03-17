local opts = { noremap = true, silent = true }

-- Remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 自作
-- 現在開いているファイル名をクリップボードにコピーする
vim.keymap.set(
  "n",
  "<Plug>(self.copy_filename)",
  function()
    local filename = vim.fn.expand("%:t:r")
    vim.fn.setreg("+", filename)
  end,
  {desc = "⭐︎Self: Copy filename."}
)

