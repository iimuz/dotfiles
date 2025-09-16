-- toggle term
-- see: <https://github.com/akinsho/toggleterm.nvim>
--
-- Terminal windowの位置などを調整する
--
-- `exe v:count1 . "ToggleTerm"`では、コマンドの前に数字を設定することで任意の端末を開くことができる。
-- 数字を設定しなければ、最初の端末を開くことができきる。

-- cluade codeコマンドのターミナルを開閉
local function claudeCodeToggle()
	local Terminal = require("toggleterm.terminal").Terminal
	local cc = Terminal:new({
		cmd = "claude",
		direction = "float",
		hidden = true,
	})
	cc:toggle()
end

-- gh dashコマンドのターミナルを開閉
local function ghDashToggle()
	local Terminal = require("toggleterm.terminal").Terminal
	local ghDash = Terminal:new({
		cmd = "gh dash",
		direction = "float",
		hidden = true,
	})
	ghDash:toggle()
end

-- lazygitコマンドのターミナルを開閉
local function lazygitToggle()
	local Terminal = require("toggleterm.terminal").Terminal
	local lazygit = Terminal:new({
		cmd = "lazygit",
		direction = "float",
		hidden = true,
	})
	lazygit:toggle()
end

-- Vifmのターミナルを開閉する
--
-- see: <https://www.reddit.com/r/neovim/comments/r5i9zi/toggle_term_vifm_best_way_to_file_explore_in_vim/>
local function vifmToggle()
	local Terminal = require("toggleterm.terminal").Terminal
	local Path = require("plenary.path")
	local path = vim.fn.tempname()
	local Vifm = Terminal:new({
		-- `:only`を利用してneovimから開く場合は、シングルカラムに修正
		cmd = ('vifm . -c "only" --choose-files "%s"'):format(path),
		direction = "float",
		close_on_exit = true,
		on_close = function()
			local data = Path:new(path):read()
			if data == "" then
				return
			end

			vim.schedule(function()
				vim.cmd("e " .. data)
			end)
		end,
	})
	Vifm:toggle()
end

return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {},
	keys = {
		{ "<Leader>Ta", ghDashToggle, desc = "⭐︎ToggleTerm: Open gh dash." },
		{ "<Leader>Tc", claudeCodeToggle, desc = "⭐︎ToggleTerm: Open claude code." },
		{
			"<Leader>Tf",
			"<cmd>exe v:count1 . \"ToggleTerm direction='float'\"<CR>",
			desc = "⭐︎ToggleTerm: Open floating terminal.",
		},
		{
			"<Leader>Th",
			"<cmd>exe v:count1 . \"ToggleTerm direction='horizontal'\"<CR>",
			desc = "⭐︎ToggleTerm: Open horizontal terminal.",
		},
		{
			"<Leader>Ti",
			"<cmd>ToggleTermSendVisualLines<CR>",
			desc = "ToggleTerm: Send selected lines to terminal.",
		},
		{ "<Leader>Tl", lazygitToggle, desc = "⭐︎ToggleTerm: Open lazygit." },
		{
			"<Leader>TL",
			"<cmd>ToggleTermSendCurrentLine<CR>",
			desc = "ToggleTerm: Send current line to terminal.",
		},
		{ "<Leader>Tn", "<cmd>ToggleTermSetName<CR>", desc = "ToggleTerm: Set a display name." },
		{ "<Leader>Tp", "<cmd>TermSelect<CR>", desc = "ToggleTerm: Select a terminal." },
		{ "<Leader>Ts", "<cmd>ToggleTermSendVisualSelection<CR>", desc = "ToggleTerm: Send selection to terminal." },
		{
			"<Leader>Tt",
			"<cmd>exe v:count1 . \"ToggleTerm direction='tab'\"<CR>",
			desc = "ToggleTerm: Open tab terminal.",
		},
		{
			"<Leader>TV",
			"<cmd>exe v:count1 . \"ToggleTerm direction='vertical'\"<CR>",
			desc = "ToggleTerm: Open vertical terminal.",
		},
		{ "<Leader>Tv", vifmToggle, desc = "⭐︎ToggleTerm: Open vifm." },
	},
}
