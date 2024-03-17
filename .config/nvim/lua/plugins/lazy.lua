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
  -- git操作
  {
    "dinhhuy258/git.nvim",
    cond = only_neovim,
    config = function() require("plugins/git") end,
  },
  -- カーソル移動をラベルで行う。
  -- VSCodeから利用するときにeasymotionが利用できないので代わりに利用する。
  -- neovim単体であれば他のpluginも利用できるが操作性を変えたくないので同じpluginを利用する。
  {
    "ggandor/leap.nvim",
    config = function() require("plugins/leap") end,
    -- Do not set lazy loading via your fancy plugin manager
    -- see: <https://github.com/ggandor/leap.nvim?tab=readme-ov-file#installation>
    lazy = false,
    dependencies = {
      "tpope/vim-repeat",
    },
  },
  -- gitの変更点を可視化
  {
    "lewis6991/gitsigns.nvim",
    cond = only_neovim,
    config = function() require("plugins/gitsigns") end,
  },
  -- Neovim builtin LSP
  {
    "neovim/nvim-lspconfig",
    cond = only_neovim,
  },
  -- fuzzy finder
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
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    cond = only_neovim,
    build = ":TSUpdate",
    config = function() require("plugins/treesitter") end,
  },
  -- visual modeで選択した文字列を囲む
  {"tpope/vim-surround"},
  -- LSP manager
  {
    "williamboman/mason.nvim",
    cond = only_neovim,
    config = function() require("mason").setup() end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    cond = only_neovim,
    config = function() require("plugins/mason-lspconfig") end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",  -- capabilityを設定
    },
  },
  -- Colorscheme - Iceberg
  {
    "cocopon/iceberg.vim",
    cond = only_neovim,
    config = function() require("plugins/iceberg") end,
  },
  -- Completion
  {
    "hrsh7th/nvim-cmp",
    -- event = 'VimEnter',
    cond = only_neovim,
    enabled = true,
    config = function() require("plugins/nvim-cmp") end,
    dependencies = {
      { "hrsh7th/cmp-buffer" },  -- 開いているバッファからのキーワード補完
      { "hrsh7th/cmp-nvim-lsp" },  -- LSPからの補完
      { "hrsh7th/cmp-path" },  -- パス補完
      -- { "petertriho/cmp-git" },  -- git issueなどの補完
      -- { "hrsh7th/cmp-emoji" },
      -- { "hrsh7th/cmp-vsnip" },
      -- { "onsails/lspkind.nvim" },
    },
  },
}

