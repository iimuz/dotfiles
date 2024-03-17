-- nvim-treesitter
-- see: <https://github.com/nvim-treesitter/nvim-treesitter>

-- VSCodeから利用した場合は無効化する
local condition = vim.g.vscode == nil

return {
  "nvim-treesitter/nvim-treesitter",
  cond = condition,
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")

    configs.setup(
      {
        ensure_installed = {
          "bash",
          "c",
          "comment",
          "cpp",
          "css",
          "csv",
          "cuda",
          "diff",
          "dockerfile",
          "git_config",
          "git_rebase",
          "gitattributes",
          "gitcommit",
          "gitignore",
          "go",
          "gomod",
          "gosum",
          "gowork",
          "html",
          "ini",
          "javascript",
          "jq",
          "jsdoc",
          "json",
          "jsonc",
          "lua",
          "make",
          "markdown_inline",
          "mermaid",
          "python",
          "rust",
          "toml",
          "typescript",
          "vim",
          "vimdoc",
          "xml",
          "yaml",
        },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      }
    )
  end,
}

