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
      { desc = "⭐︎ToggleTerm: Open lazygit." }
    )

    -- vifm
    -- see: <https://www.reddit.com/r/neovim/comments/r5i9zi/toggle_term_vifm_best_way_to_file_explore_in_vim/>
    local Path = require("plenary.path")
    local path = vim.fn.tempname()
    local Vifm = Terminal:new {
      cmd = ('vifm . . --choose-files "%s"'):format(path),
      direction = "float",
      close_on_exit = true,
      on_close = function()
        local data = Path:new(path):read()
        vim.schedule(function()
          vim.cmd('e ' .. data)
        end)
      end
    }
    function _VifmToggle()
      Vifm:toggle()
    end

    set(
      "n",
      "<Plug>(toggleterm.vifm)",
      "<cmd>lua _VifmToggle()<CR>",
      { desc = "⭐︎ToggleTerm: Open vifm." }
    )
  end,
}
