-- folke/trouble.nvim
-- see: <https://github.com/folke/trouble.nvim?tab=readme-ov-file>
--
-- DiagnosticsやLSP Referencesなどを見やすくする

return {
	"folke/trouble.nvim",
	event = { "VimEnter" },
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
	keys = {
		{
			"<Leader>bd",
			function()
				require("trouble").toggle("document_diagnostics")
			end,
			desc = "Trouble: Toggle document diagnostics.",
		},
		{
			"<Leader>bl",
			function()
				require("trouble").toggle("loclist")
			end,
			desc = "Trouble: Toggle location list.",
		},
		{
			"<Leader>bq",
			function()
				require("trouble").toggle("quickfix")
			end,
			desc = "Trouble: Toggle quickfix.",
		},
		{
			"<Leader>br",
			function()
				require("trouble").toggle("lsp_references")
			end,
			desc = "Trouble: Toggle LSP references.",
		},
		{
			"<Leader>bt",
			function()
				require("trouble").toggle()
			end,
			desc = "Trouble: Toggle.",
		},
		{
			"<Leader>bw",
			function()
				require("trouble").toggle("workspace_diagnostics")
			end,
			desc = "Trouble: Toggle workspace diagnostics.",
		},
	},
}
