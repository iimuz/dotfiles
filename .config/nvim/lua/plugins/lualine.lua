-- nvim-lualine/lualine.nvim
-- see: <https://github.com/nvim-lualine/lualine.nvim>
--
-- status lineの変更

local function diff_source()
	local gitsigns = vim.b.gitsigns_status_dict
	if gitsigns then
		return {
			added = gitsigns.added,
			modified = gitsigns.changed,
			removed = gitsigns.removed,
		}
	end
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"lewis6991/gitsigns.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	event = { "VimEnter" },
	config = function()
		require("lualine").setup({
			options = {
				globalstatus = true,
				always_show_tabline = false,
			},
			sections = {
				lualine_a = {
					"mode",
				},
				lualine_b = {
					{ "b:gitsigns_head", icon = { "" } },
					{ "diff", symbols = { added = " ", modified = " ", removed = " " }, source = diff_source },
					"diagnostics",
				},
				lualine_c = {
					{
						"filename",
						newfile_status = true,
						path = 1,
						shorting_target = 24,
						symbols = { modified = "_󰷥", readonly = " ", newfile = "󰄛" },
					},
				},

				lualine_x = {
					"encoding",
					{ "fileformat", icons_enabled = true },
					{ "filetype" },
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			tabline = {
				lualine_a = {
					{
						"tabs",
						mode = 2,
						show_modified_status = false,
						-- the default (1/3 of the screen width) hides tabs that do not fit behind "..."
						max_length = function()
							-- lualine does not count the "..." tabs on both sides and the section
							-- separator (12 columns in total) against max_length
							return vim.o.columns - 12
						end,
					},
				},
			},
		})
	end,
}
