-- Telescope.nvimの設定
local opts = { noremap = true, silent = true }

-- `Ctr + P`でファイル一覧を表示
vim.api.nvim_set_keymap("n", '<C-p>', '<cmd>Telescope find_files find_command=rg,--files,--hidden,--glob,!*.git<CR>', opts)

