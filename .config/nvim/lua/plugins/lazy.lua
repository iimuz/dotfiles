-- lazyの自動セットアップ
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- どこからneovimを利用しているかによって有効化するpluginを変更するためのフラグ
-- only_neovim: Trueの場合は、vscodeの拡張機能から起動した場合は利用しない
-- only_vscode: Trueの場合は、vscodeの拡張機能から起動した場合のみ利用する
local only_neovim = true
local only_vscode = false
if vim.g.vscode ~= nil then -- vscodeから利用している
  only_neovim = false
  only_vscode = true
end

-- プラグインの設定、それぞれのpluginの設定は別ファイルに記載する
require("lazy").setup {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    branch = "0.1.x",
    cond = only_neovim,
    config = function() require("plugins/telescope") end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- nvim-treesitterを利用するとエラーが発生するため無効化
      -- see: <https://github.com/nvim-treesitter/nvim-treesitter/issues/5536>
      -- "nvim-treesitter/nvim-treesitter"
    }
  },
  -- カーソル移動をラベルで行う(easymotionの代替)
  -- ライン移動ができないのと1文字で移動する時にラベルをつけてくれないが、動作するので利用中。
  {
    "ggandor/lightspeed.nvim",
    cond = only_vscode,
    config = function() require("plugins/lightspeed") end
  },
  -- visual modeで選択した文字列を囲む
  {
    "tpope/vim-surround",
    cond = only_vscode,
  }
}

