print("lazy vscode")

require('lazy').setup {
  -- カーソル移動をラベルで行う(easymotionの代替)
  -- ライン移動ができないのと1文字で移動する時にラベルをつけてくれないが、動作するので利用中。
  {
    'ggandor/lightspeed.nvim',
    config = function() require("plugins/lightspeed") end
  },
  -- visual modeで選択した文字列を囲む
  {'tpope/vim-surround'}
}

