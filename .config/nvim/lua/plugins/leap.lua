-- leapの設定
-- see: <https://github.com/ggandor/leap.nvim>
--
-- カーソル移動をラベルで行う。
-- VSCodeから利用するときにeasymotionが利用できないので代わりに利用する。
-- neovim単体であれば他のpluginも利用できるが操作性を変えたくないので同じpluginを利用する。

return {
  "ggandor/leap.nvim",
  -- Do not set lazy loading via your fancy plugin manager
  -- see: <https://github.com/ggandor/leap.nvim?tab=readme-ov-file#installation>
  lazy = false,
  dependencies = {
    "tpope/vim-repeat",
  },
  config = function()
    vim.keymap.set({'n', 'x', 'o'}, '<Leader>s',  '<Plug>(leap-forward)')
    vim.keymap.set({'n', 'x', 'o'}, '<Leader>S',  '<Plug>(leap-backward)')
  end,
}

