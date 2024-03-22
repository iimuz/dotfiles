local opts = { noremap = true, silent = true }

-- Remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 自作
local set = vim.keymap.set
-- 現在開いているファイル名をクリップボードにコピーする
set(
  "n",
  "<Plug>(self.copy_filename)",
  function()
    local filename = vim.fn.expand("%:t:r")
    vim.fn.setreg("+", filename)
  end,
  { desc = "⭐︎Self: Copy filename." }
)
-- TerminalのECSコマンドの設定
set(
  "t",
  "<c-]>",
  "<c-\\><c-n>",
  { desc = "⭐︎Self: Escape from terminal." }
)

-- Quickfix
set(
  "n",
  "<Plug>(quickfix.open)",
  "<cmd>copen<CR>",
  { desc = "⭐︎Quickfix: Open." }
)
set(
  "n",
  "<Plug>(quickfix.close)",
  "<cmd>cclose<CR>",
  { desc = "⭐︎Quickfix: Close." }
)
set(
  "n",
  "<Plug>(quickfix.next)",
  "<cmd>cnext<CR>",
  { desc = "⭐︎Quickfix: Next." }
)
set(
  "n",
  "<Plug>(quickfix.previous)",
  "<cmd>cprevious<CR>",
  { desc = "⭐︎Quickfix: Previous." }
)
-- Location
set(
  "n",
  "<Plug>(location.open)",
  "<cmd>lopen<CR>",
  { desc = "⭐︎Location: Open." }
)
set(
  "n",
  "<Plug>(location.close)",
  "<cmd>lclose<CR>",
  { desc = "⭐︎Location: Close." }
)
set(
  "n",
  "<Plug>(location.next)",
  "<cmd>lnext<CR>",
  { desc = "⭐︎Location: Next." }
)
set(
  "n",
  "<Plug>(location.previous)",
  "<cmd>lprevious<CR>",
  { desc = "⭐︎Location: Previous." }
)
