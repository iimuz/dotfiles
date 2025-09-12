-- folke/trouble.nvim
-- see: <https://github.com/folke/trouble.nvim?tab=readme-ov-file>
--
-- DiagnosticsやLSP Referencesなどを見やすくする

return {
	"folke/trouble.nvim",
	event = { "VimEnter" },
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
}
