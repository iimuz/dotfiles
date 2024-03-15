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

-- Telescopeのkeymapsで参照できるようにするため
for k, v in pairs(require("telescope.builtin")) do
  if type(v) == "function" then
    vim.keymap.set('n', '<Plug>(telescope.' .. k .. ')', v)
  end
end

