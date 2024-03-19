-- Telescope.nvimの設定
--
-- fuzzy finder
-- TelescopeとTelescope拡張機能を管理する。
-- 利用例:
-- - `Ctrl + p`: ファイル一覧の表示
-- - `Ctrl + P`: 登録コマンドの一覧表示
-- - プレビュー画面の移動: `Ctrl + u`, `Ctrl + d`

-- VSCodeから利用する場合は無効化
local condition = vim.g.vscode == nil

return {
  -- Telescope本体
  -- see: <https://github.com/nvim-telescope/telescope.nvim>
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    branch = "0.1.x",
    cond = condition,
    dependencies = {
      "nvim-lua/plenary.nvim",
      'nvim-tree/nvim-web-devicons',
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      -- `<Leader>p`でファイル一覧を表示
      vim.keymap.set(
        "n",
        '<Leader>p',
        '<cmd>Telescope find_files find_command=rg,--files,--hidden,--glob,!*.git<CR>',
        { desc = "⭐︎Telescope: Find files." }
      )
      -- `<Leader>P`でキー登録したコマンドパレットを表示
      -- see: <https://blog.atusy.net/2022/11/03/telescope-as-command-pallete/>
      vim.keymap.set(
        { "n", "v" },
        '<Leader>P',
        function()
          require('telescope.builtin').keymaps()
          vim.cmd("normal! i⭐︎")
        end,
        { desc = "⭐︎Telescope: Open command palet(keymaps)." }
      )
      -- `<Leader>C`でコマンド一覧を表示
      vim.keymap.set(
        "n",
        '<Leader>c',
        function()
          require('telescope.builtin').commands()
        end,
        { desc = "⭐︎Telescope: Open command list." }
      )
      vim.keymap.set(
        "n",
        '<Leader>C',
        function()
          require('telescope.builtin').command_history()
        end,
        { desc = "⭐︎Telescope: Open command history list." }
      )

      -- コマンドパレットでの検索用のコマンド登録
      vim.keymap.set(
        "n",
        "<Plug>(telescope.buffers)",
        function()
          require("telescope.builtin").buffers()
        end,
        { desc = "⭐︎Telescope: Open Buffer." }
      )
      vim.keymap.set(
        "n",
        "<Plug>(telescope.colorscheme)",
        function()
          require("telescope.builtin").colorscheme()
        end,
        { desc = "Telescope: Color scheme." }
      )
      vim.keymap.set(
        "n",
        "<Plug>(telescope.git_commits)",
        function()
          require("telescope.builtin").git_commits()
        end,
        { desc = "⭐︎Telescope: git commits." }
      )
      vim.keymap.set(
        "n",
        "<Plug>(telescope.git_status)",
        function()
          require("telescope.builtin").git_status()
        end,
        { desc = "⭐︎Telescope: git status." }
      )
      vim.keymap.set(
        "n",
        "<Plug>(telescope.help_tags)",
        function()
          require("telescope.builtin").help_tags()
        end,
        { desc = "⭐︎Telescope: Help." }
      )
      vim.keymap.set(
        "n",
        "<Plug>(telescope.grep)",
        function()
          require("telescope.builtin").live_grep()
        end,
        { desc = "⭐︎Telescope: Search in Workspace." }
      )
      vim.keymap.set(
        "n",
        "<Plug>(telescope.oldfiles)",
        function()
          require("telescope.builtin").oldfiles()
        end,
        { desc = "⭐︎Telescope: Open file from history." }
      )
      vim.keymap.set(
        "n",
        "<Plug>(telescope.registers)",
        function()
          require("telescope.builtin").registers()
        end,
        { desc = "⭐︎Telescope: Show registers." }
      )
      vim.keymap.set(
        "n",
        "<Plug>(telescope.vim_options)",
        function()
          require("telescope.builtin").vim_options()
        end,
        { desc = "Telescope: Show vim options." }
      )
      -- TelescopeでLSPコマンド
      vim.keymap.set(
        "n",
        "<Plug>(telescope.show_referneces)",
        require("telescope.builtin").lsp_references,
        { desc = "Telescope: Show lsp referneces." }
      )
    end,
  },
  -- Telescopeのファイルブラウザ拡張
  -- see: <https://github.com/nvim-telescope/telescope-file-browser.nvim>
  {
    "nvim-telescope/telescope-file-browser.nvim",
    cond = condition,
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim"
    },
    config = function()
      require("telescope").load_extension("file_browser")

      vim.keymap.set(
        "n",
        "<Plug>telescope.file_browser.open",
        "<cmd>Telescope file_browser<CR>",
        { desc = "⭐︎Telescope FileBrowser: Open file browser." }
      )
    end,
  },
}
