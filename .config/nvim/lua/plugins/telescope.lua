-- Telescope.nvimの設定

-- `<Leader>p`でファイル一覧を表示
vim.keymap.set(
  "n",
  '<Leader>p',
  '<cmd>Telescope find_files find_command=rg,--files,--hidden,--glob,!*.git<CR>',
  {desc = "⭐︎Find files."}
)
-- `<Leader>P`でコマンドパレットを表示
vim.keymap.set(
  "n",
  '<Leader>P',
  function()
    require('telescope.builtin').keymaps()
    vim.cmd("normal! i⭐︎")
  end,
  {desc = "⭐︎Open command palet."}
)

-- コマンドパレットでの検索用のコマンド登録
vim.keymap.set(
  "n",
  "<Plug>(telescope.grep)",
  function()
    require("telescope.builtin").live_grep()
  end,
  {desc = "⭐︎Search"}
)

-- Telescopeのkeymapsで参照できるようにするため
-- see: <https://blog.atusy.net/2022/11/03/telescope-as-command-pallete/>
for k, v in pairs(require("telescope.builtin")) do
  if type(v) == "function" then
    vim.keymap.set('n', '<Plug>(telescope.' .. k .. ')', v)
  end
end

