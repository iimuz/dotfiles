-- nvim-lualine/lualine.nvim
-- see: <https://github.com/nvim-lualine/lualine.nvim>
--
-- status lineの変更

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

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
	cond = condition,
	event = { "VimEnter" },
	config = function()
		require("lualine").setup({
			options = {
				globalstatus = true,
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
		})
	end,
}
