-- yetone/avante.nvim
-- see: <https://github.com/yetone/avante.nvim>
--
-- Use your Noevim like using Curosr AI IDE.
-- sidekick を導入したので使わなくなった。

return {
	"yetone/avante.nvim",
	enable = false,
	cmd = {
		"AvanteAsk",
		"AvanteChat",
		"AvanteEdit",
		"AvanteFocus",
		"AvanteToggle",
	},
	event = "VeryLazy",
	version = false,
	---@module 'avante'
	---@type avante.Config
	opts = {
		instructions_file = "AGENTS.md",
		behaviour = { auto_set_keymaps = false },
		hints = { enabled = false }, -- virtual textを利用したキーマップ表示をoff
		windows = {
			input = { height = 16 },
		},
		input = {
			provider = "snacks",
			provider_opts = {
				-- Additional snacks.input options
				title = "Avante Input",
				icon = " ",
			},
		},
		-- system_prompt as function ensures LLM always has latest MCP server state
		-- This is evaluated for every message, even in existing chats
		system_prompt = function()
			local hub = require("mcphub").get_hub_instance()
			return hub and hub:get_active_servers_prompt() or ""
		end,
		-- Using function prevents requiring mcphub before it's loaded
		custom_tools = function()
			return {
				require("mcphub.extensions.avante").mcp_tool(),
			}
		end,
		provider = "copilot",
		providers = {
			copilot = {
				model = "gpt-4.1",
			},
		},
	},
	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	build = "make",
	-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
		"folke/snacks.nvim", -- for input provider snacks
		"zbirenbaum/copilot.lua", -- for providers='copilot'
		{
			-- Make sure to set this up properly if you have lazy=true
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
		{
			"ravitemer/mcphub.nvim",
			opts = {
				extensions = {
					avante = {
						make_slash_commands = true, -- make /slash commands from MCP server prompts
					},
				},
			},
		},
	},
	keys = {
		{
			"<Leader>aa",
			"<cmd>AvanteAsk<CR>",
			desc = "Avante: Ask mode.",
			mode = { "n", "v" },
		},
		{
			"<Leader>ac",
			"<cmd>AvanteChat<CR>",
			desc = "Avante: Chat mode.",
			mode = { "n" },
		},
		{
			"<Leader>au",
			"<cmd>AvanteSwitchProvider copilot_claude<CR>",
			desc = "Avante: Switch provider to GitHub Copilot Calude.",
			mode = { "n" },
		},
		{
			"<Leader>ae",
			"<cmd>AvanteEdit<CR>",
			desc = "Avante: Edit mode.",
			mode = { "n", "v" },
		},
		{
			"<Leader>af",
			"<cmd>AvanteFocus<CR>",
			desc = "Avante: Switch focus to/from the sidebar.",
			mode = { "n" },
		},
		{
			"<Leader>ag",
			"<cmd>AvanteSwitchProvider copilot_gpt<CR>",
			desc = "Avante: Switch provider to GitHub Copilot GPT.",
			mode = { "n" },
		},
		{
			"<Leader>ah",
			"<cmd>AvanteHistory<CR>",
			desc = "Avante: Show history.",
			mode = { "n" },
		},
		{
			"<Leader>am",
			"<cmd>AvanteModels<CR>",
			desc = "Avante: Select model.",
			mode = { "n" },
		},
		{
			"<Leader>as",
			"<cmd>AvanteStop<CR>",
			desc = "Avante: Stop the current AI request.",
			mode = { "n" },
		},
		{
			"<Leader>at",
			"<cmd>AvanteToggle<CR>",
			desc = "Avante: Toggle the sidebar.",
			mode = { "n", "v" },
		},
	},
}
