-- github/copilot.vim
-- see: <https://github.com/github/copilot.vim>
--
-- GitHub Copilot Plugin.

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

-- Copilot pluginを有効にするためのキーマップ
local set = vim.keymap.set
set(
  "n",
  "<Plug>copilot.load_plugin",
  "<cmd>Copilot status<CR>",
  { desc = "⭐︎Copilot: Load copilot plugin." }
)

return {
  "github/copilot.vim",
  cond = condition,
  cmd = "Copilot",
  config = function()
    set(
      "n",
      "<Plug>copilot.status",
      "<cmd>Copilot status<CR>",
      { desc = "Copilot: Show status." }
    )
    set(
      "n",
      "<Plug>copilot.setup",
      "<cmd>Copilot setup<CR>",
      { desc = "Copilot: Setup." }
    )
    set(
      "n",
      "<Plug>copilot.enable",
      "<cmd>Copilot enable<CR>",
      { desc = "Copilot: Enable." }
    )
    set(
      "n",
      "<Plug>copilot.disable",
      "<cmd>Copilot disable<CR>",
      { desc = "Copilot: Disable." }
    )
    set(
      "n",
      "<Plug>copilot.panel",
      "<cmd>Copilot panel<CR>",
      { desc = "Copilot: Show panel." }
    )
    set(
      "n",
      "<Plug>copilot.restart",
      "<cmd>Copilot restart<CR>",
      { desc = "Copilot: Restart." }
    )
    set(
      "n",
      "<Plug>copilot.signin",
      "<cmd>Copilot signin<CR>",
      { desc = "Copilot: Signin." }
    )
    set(
      "n",
      "<Plug>copilot.signout",
      "<cmd>Copilot singout<CR>",
      { desc = "Copilot: Signout." }
    )
  end,
}
