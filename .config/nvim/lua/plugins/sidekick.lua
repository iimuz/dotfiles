-- folke/sidekick.nvim
-- <https://github.com/folke/sidekick.nvim>
--
-- LLM CLI Manager for Neovim.

return {
	"folke/sidekick.nvim",
	config = function()
		function github_copilot_token()
			local e = {}
			if vim.fn.executable("pass") == 1 then
				local token = (vim.fn.systemlist("pass show github/copilot-token 2>/dev/null") or { "" })[1]
				if token and token ~= "" then
					e.GITHUB_TOKEN = token
				end
			else
				e.GH_CONFIG_DIR = vim.env.HOME .. "/.config/gh-copilot"
			end

			return e
		end
		require("sidekick").setup({
			-- nes = { enabled = false },
			cli = {
				tools = {
					copilot = {
						cmd = {
							"copilot",
							"--deny-tool=shell(git checkout:*)",
							"--deny-tool=shell(git push:*)",
							"--deny-tool=shell(git rebase:*)",
							"--deny-tool=shell(git reset:*)",
							"--deny-tool=shell(git switch:*)",
							"--deny-tool=shell(npm remove:*)",
							"--deny-tool=shell(npm uninstall:*)",
							"--deny-tool=shell(rm -f:*)",
							"--deny-tool=shell(rm -rf:*)",
							"--deny-tool=shell(sudo:*)",
							"--allow-all-tools",
						},
						env = github_copilot_token(),
					},
					copilot_resume = {
						cmd = {
							"copilot",
							"--deny-tool=shell(git checkout:*)",
							"--deny-tool=shell(git push:*)",
							"--deny-tool=shell(git rebase:*)",
							"--deny-tool=shell(git reset:*)",
							"--deny-tool=shell(git switch:*)",
							"--deny-tool=shell(npm remove:*)",
							"--deny-tool=shell(npm uninstall:*)",
							"--deny-tool=shell(rm -f:*)",
							"--deny-tool=shell(rm -rf:*)",
							"--deny-tool=shell(sudo:*)",
							"--allow-all-tools",
							"--resume",
						},
						env = github_copilot_token(),
					},
				},
			},
		})
	end,
	keys = {
		{
			"<tab>",
			function()
				-- if there is a next edit, jump to it, otherwise apply it if any
				if not require("sidekick").nes_jump_or_apply() then
					return "<Tab>" -- fallback to normal tab
				end
			end,
			expr = true,
			desc = "Goto/Apply Next Edit Suggestion",
		},
		{
			"<c-.>",
			function()
				require("sidekick.cli").toggle()
			end,
			desc = "Sidekick Toggle",
			mode = { "n", "t", "i", "x" },
		},
		{
			"<leader>sa",
			function()
				require("sidekick.cli").toggle()
			end,
			desc = "Sidekick Toggle CLI",
		},
		{
			"<leader>sc",
			function()
				require("sidekick.cli").toggle({ name = "copilot", focus = true })
			end,
			desc = "Sidekick Toggle GitHub Copilot CLI",
		},
		{
			"<leader>sd",
			function()
				require("sidekick.cli").close()
			end,
			desc = "Detach a CLI Session",
		},
		{
			"<leader>sf",
			function()
				require("sidekick.cli").send({ msg = "{file}" })
			end,
			desc = "Send File",
		},
		{
			"<leader>sp",
			function()
				require("sidekick.cli").prompt()
			end,
			mode = { "n", "x" },
			desc = "Sidekick Select Prompt",
		},
		{
			"<leader>ss",
			function()
				require("sidekick.cli").select()
			end,
			-- Or to select only installed tools:
			-- require("sidekick.cli").select({ filter = { installed = true } })
			desc = "Select CLI",
		},
		{
			"<leader>st",
			function()
				require("sidekick.cli").send({ msg = "{this}" })
			end,
			mode = { "x", "n" },
			desc = "Send This",
		},
		{
			"<leader>sv",
			function()
				require("sidekick.cli").send({ msg = "{selection}" })
			end,
			mode = { "x" },
			desc = "Send Visual Selection",
		},
	},
}
