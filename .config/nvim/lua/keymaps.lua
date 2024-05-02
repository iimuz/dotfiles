-- Keymaps settings.
--
-- which-keyで設定できないようなキーマップの設定を行う。
local opts = { noremap = true, silent = true }

-- Remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local set = vim.keymap.set
-- TerminalのECSコマンドの設定
set("t", "<c-]>", "<c-\\><c-n>", { desc = "⭐︎Self: Escape from terminal." })
