-- lightspeedの設定
--
-- line移動のコマンドが存在しないので、行末に移動するのであれば `Enter` で指定できる。
local opts = { noremap = true, silent = true }

-- lightspeedのデフォルトのキーバインドを全て無効化
vim.go.lightspeed_no_default_keymaps = true

-- Move to word
vim.api.nvim_set_keymap("", "<Leader>s", "<Plug>Lightspeed_s", opts)
vim.api.nvim_set_keymap("", "<Leader>S", "<Plug>Lightspeed_S", opts)

