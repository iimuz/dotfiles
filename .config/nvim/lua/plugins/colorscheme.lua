-- Colorscheme
--
--Colorschemeは、どれか一つで良いので全てここにまとめる

return {
	-- catppuccin
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		enabled = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "frappe",
				integrations = {
					diffview = true,
				},
			})

			vim.cmd([[ colorscheme catppuccin ]])
		end,
	},
	-- iceverg
	-- see: <https://github.com/cocopon/iceberg.vim>
	{
		"cocopon/iceberg.vim",
		lazy = false,
		enabled = false,
		config = function()
			vim.opt.termguicolors = true
			vim.opt.background = "dark"
			vim.cmd([[ colorscheme iceberg ]])
		end,
	},
	-- nightfox
	-- see: <https://github.com/EdenEast/nightfox.nvim>
	{
		"EdenEast/nightfox.nvim",
		lazy = false,
		enabled = false,
		config = function()
			vim.opt.termguicolors = true
			vim.opt.background = "dark"
			vim.cmd([[ colorscheme nightfox ]])
		end,
	},
	{
		"projekt0n/github-nvim-theme",
		lazy = false,
		enabled = false,
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			require("github-theme").setup({})
			vim.cmd([[ colorscheme github_dark ]])
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		enabled = true,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "night",
				-- dim non-active neovim splits within the focused tmux pane
				dim_inactive = true,
				on_highlights = function(hl, _)
					-- match neovim split borders to tmux inactive pane border color
					hl.WinSeparator = { fg = "#3b4261" }
				end,
			})

			vim.cmd([[ colorscheme tokyonight-night ]])

			-- track focus state to allow ColorScheme autocmd to reapply correctly
			local focused = true

			local function apply_focused_profile()
				vim.api.nvim_set_hl(0, "Normal", { bg = "#1a1b26", fg = "#c0caf5" })
				vim.api.nvim_set_hl(0, "NormalNC", { bg = "#16161e" })
			end

			local function apply_unfocused_profile()
				-- converge all splits to a single readable dim when tmux pane loses focus
				vim.api.nvim_set_hl(0, "Normal", { bg = "#16161e", fg = "#c0caf5" })
				vim.api.nvim_set_hl(0, "NormalNC", { bg = "#16161e" })
			end

			local group = vim.api.nvim_create_augroup("PaneFocusHighlight", { clear = true })

			vim.api.nvim_create_autocmd("FocusLost", {
				group = group,
				callback = function()
					focused = false
					vim.schedule(apply_unfocused_profile)
				end,
			})

			vim.api.nvim_create_autocmd("FocusGained", {
				group = group,
				callback = function()
					focused = true
					vim.schedule(apply_focused_profile)
				end,
			})

			vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = function()
				focused = true
				vim.schedule(apply_focused_profile)
			end })

			-- re-apply current profile after colorscheme reload so focus state is not lost;
			-- also force winbar re-evaluation because nvim_set_hl alone does not trigger it
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = group,
				callback = function()
					vim.schedule(function()
						if focused then
							apply_focused_profile()
						else
							apply_unfocused_profile()
						end
						vim.cmd.redrawstatus({ bang = true, mods = { emsg_silent = true } })
					end)
				end,
			})
		end,
	},
}
