-- Colorscheme 
--
--Colorschemeは、どれか一つで良いので全てここにまとめる


-- VSCodeから利用する場合は無効化する
local condition = vim.g.vscode == nil

-- iceverg
-- see: <https://github.com/cocopon/iceberg.vim>
-- return {
--   "cocopon/iceberg.vim",
--   cond = condition,
--   config = function()
--     vim.opt.termguicolors = true
--     vim.opt.background = "dark"
--     vim.cmd [[ colorscheme iceberg ]]
--   end,
-- }

-- nightfox
-- see: <https://github.com/EdenEast/nightfox.nvim>
return {
  "EdenEast/nightfox.nvim",
  cond = condition,
  config = function()
    vim.opt.termguicolors = true
    vim.opt.background = "dark"
    vim.cmd [[ colorscheme nightfox ]]
  end,
}

