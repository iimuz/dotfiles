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
    enabled = true,
    config = function()
      vim.opt.termguicolors = true
      vim.opt.background = "dark"
      vim.cmd [[ colorscheme nightfox ]]
    end,
  }
}

