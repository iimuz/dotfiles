-- toggle term
-- see: <https://github.com/akinsho/toggleterm.nvim>
--
-- Terminal windowの位置などを調整する

return {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    require("toggleterm").setup({})

    -- Telescopeの検索用のキーマップを登録
    local set = vim.keymap.set
    set(
      "n",
      "<Plug>(toggleterm.open.horizontal)",
      "<cmd>ToggleTerm direction='horizontal'<CR>",
      { desc = "⭐︎ToggleTerm: Open horizontal terminal." }
    )
    set(
      "n",
      "<Plug>(toggleterm.open.vertical)",
      "<cmd>ToggleTerm size=180 direction='vertical'<CR>",
      { desc = "ToggleTerm: Open vertical terminal." }
    )
    set(
      "n",
      "<Plug>(toggleterm.open.float)",
      "<cmd>ToggleTerm direction='float'<CR>",
      { desc = "⭐︎ToggleTerm: Open floating terminal." }
    )

    set(
      "n",
      "<Plug>(toggleterm.send.currentLine)",
      "<cmd>ToggleTermSendCurrentLine<CR>",
      { desc = "ToggleTerm: Send current line to terminal." }
    )
    set(
      "v",
      "<Plug>(toggleterm.send.visualLines)",
      "<cmd>ToggleTermSendVisualLines<CR>",
      { desc = "ToggleTerm: Send selected lines to terminal." }
    )
    set(
      "v",
      "<Plug>(toggleterm.send.visualSelection)",
      "<cmd>ToggleTermSendVisualSelection<CR>",
      { desc = "ToggleTerm: Send selection to terminal." }
    )

    -- lazygit
    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new({
      cmd = "lazygit",
      direction = "float",
      hidden = true,
    })
    function _LazygitToggle()
      lazygit:toggle()
    end
    set(
      "n",
      "<Plug>(toggleterm.layzgit)",
      "<cmd>lua _LazygitToggle()<CR>",
      { desc = "⭐︎ToggleTerm: Opne lazygit." }
    )
  end,
}
