-- folke/sidekick.nvim
-- <https://github.com/folke/sidekick.nvim>
--
-- LLM CLI Manager for Neovim.

return {
	"folke/sidekick.nvim",
	config = function()
		local function github_copilot_token()
			local e = {}
			local gh_env = vim.env.GH_COPILOT_CONFIG_DIR
			local gh_default = vim.env.HOME .. "/.config/gh-copilot"
			local pass_item_name = "github/copilot-token"
			if gh_env and vim.fn.isdirectory(gh_env) == 1 then
				e.GH_CONFIG_DIR = gh_env
			elseif vim.fn.isdirectory(gh_default) == 1 then
				e.GH_CONFIG_DIR = gh_default
			elseif vim.fn.executable("pass") == 1 then
				local token = (vim.fn.systemlist("pass show " .. pass_item_name .. " 2>/dev/null") or { "" })[1]
				if token and token ~= "" then
					e.GITHUB_TOKEN = token
				end
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
							-- 共通 skills のアクセスチェックが入るため
							"--add-dir=~/.config/.copilot/skills",
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
							-- 共通 skills のアクセスチェックが入るため
							"--add-dir=~/.config/.copilot/skills",
							"--resume",
						},
						env = github_copilot_token(),
					},
				},
				prompts = {
					commit = ""
						.. "Commit ONLY the already staged changes using the commit message generator agent. "
						.. "Be sure to start the agent and use the skill through the agent. "
						.. "Do not start the skill directly.",
					pr_create = ""
						.. "Create a pull request based on the changes in the current branch. "
						.. "Use the 'create pr' agent to generate the pull request. "
						.. "Write the pull request description in Japanese. "
						.. "Be sure to start the agent and use the skill through the agent. "
						.. "Do not start the skill directly.",
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
