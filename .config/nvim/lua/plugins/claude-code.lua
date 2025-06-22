-- greggh/claude-code
-- see: <https://github.com/greggh/claude-code.nvim>
--
-- Claude codeの統合

return {
  "greggh/claude-code.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for git operations
  },
  opts = {
    window = {
      position = "rightbelow vsplit"
    },
  },
}
