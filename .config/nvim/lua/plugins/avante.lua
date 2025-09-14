-- yetone/avante.nvim
-- see: <https://github.com/yetone/avante.nvim>
--
-- Use your Noevim like using Curosr AI IDE.

return {
	"yetone/avante.nvim",
	cmd = { "AvanteAsk", "AvanteChat", "AvanteEdit", "AvanteFocus", "AvanteToggle" },
	version = "*", -- always pull the latest release version
	opts = {
		behaviour = { auto_set_keymaps = false },
		hints = { enabled = false }, -- virtual textを利用したキーマップ表示をoff
		windows = {
			input = { height = 16 },
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
		provider = "copilot_gpt",
		providers = {
			copilot_gpt = {
				__inherited_from = "copilot",
				model = "gpt-4.1",
			},
			copilot_claude = {
				__inherited_from = "copilot",
				model = "claude-sonnet-4",
			},
		},
	},
	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	build = "make",
	-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		"echasnovski/mini.pick", -- for file_selector provider mini.pick
		"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
		"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
		"ibhagwan/fzf-lua", -- for file_selector provider fzf
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
		"zbirenbaum/copilot.lua", -- for providers='copilot'
		{
			-- support for image pasting
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			enabled = false,
			opts = {
				-- recommended settings
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
					-- required for Windows users
					use_absolute_path = true,
				},
			},
		},
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
