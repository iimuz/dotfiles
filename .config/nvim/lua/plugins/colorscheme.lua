-- Colorscheme 
--
--Colorschemeは、どれか一つで良いので全てここにまとめる


-- VSCodeから利用する場合は無効化する
local condition = vim.g.vscode == nil

return {
  -- iceverg
  -- see: <https://github.com/cocopon/iceberg.vim>
  {
    "cocopon/iceberg.vim",
    cond = condition,
    lazy = false,
    enabled = false,
    config = function()
      vim.opt.termguicolors = true
      vim.opt.background = "dark"
      vim.cmd [[ colorscheme iceberg ]]
    end,
  },
  -- nightfox
  -- see: <https://github.com/EdenEast/nightfox.nvim>
  {
    "EdenEast/nightfox.nvim",
    cond = condition,
    lazy = false,
    enabled = false,
    config = function()
      vim.opt.termguicolors = true
      vim.opt.background = "dark"
      vim.cmd [[ colorscheme nightfox ]]
    end,
  },
  {
    'projekt0n/github-nvim-theme',
    cond = condition,
    lazy = false,
    enabled = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('github-theme').setup({})
      vim.cmd [[ colorscheme github_dark ]]
    end,
  },
  {
    "folke/tokyonight.nvim",
    cond = condition,
    lazy = false,
    enabled = true,
    priority = 1000,
    opts = {},
    config = function()
      vim.cmd [[ colorscheme tokyonight-night ]]
    end,
  },
}

