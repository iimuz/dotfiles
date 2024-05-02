-- folke/trouble.nvim
-- see: <https://github.com/folke/trouble.nvim?tab=readme-ov-file>
--
-- DiagnosticsやLSP Referencesなどを見やすくする

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
	"folke/trouble.nvim",
	cond = condition,
	event = { "VimEnter" },
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
}
