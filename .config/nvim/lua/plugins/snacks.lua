-- folke/snacks.nvim
-- <https://github.com/folke/snacks.nvim>
--
-- A collection of QoL plugins for Neovim.

-- 同じフォルダのファイルのみを検索する
--
-- see: <https://eiji.page/blog/neovim-snacks-picker-intro/>
local function find_files_in_current_folder()
	require("snacks").picker({
		finder = "proc",
		cmd = "find",
		args = { vim.fn.expand("%:h"), "-type", "f", "-not", "-name", vim.fn.expand("%:t") },
		---@param item snacks.picker.finder.Item
		transform = function(item)
			item.file = item.text
		end,
	})
end

-- 選択しているファイルのfilenameをカーソル位置に挿入する
local function insert_filename_without_suffix(picker, _)
	local item = picker:current()
	local filepath = item.file or item.path or item.filename
	local filename = vim.fn.fnamemodify(filepath, ":t:r")
	picker:close()
	vim.api.nvim_put({ filename }, "c", false, true)
end

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = false },
		dashboard = { enabled = false },
		dim = { enabled = false },
		explorer = { enabled = true },
		indent = { enabled = true },
		input = { enabled = true },
		picker = {
			enabled = true,
			formatters = {
				file = {
					filename_first = true,
					truncate = 100,
				},
			},
			sources = {
				explorer = {
					hidden = true,
					auto_close = true,
					win = {
						list = {
							keys = {
								-- デフォルトで `S-CR` に割り当てられているが動作しないので `O` に設定
								-- see: <https://github.com/folke/snacks.nvim/discussions/1362>
								["O"] = { { "pick_win", "jump" }, mode = { "n", "i" } },
							},
						},
					},
				},
				files = { hidden = true },
				grep = { hidden = true },
				grep_word = { hidden = true },
			},
			actions = {
				insert_filename_without_suffix = insert_filename_without_suffix,
			},
			win = {
				input = {
					keys = {
						["<C-f>"] = { "insert_filename_without_suffix", mode = { "n", "i" } },
					},
				},
			},
		},
		notifier = { enabled = true },
		quickfile = { enabled = false },
		scope = { enabled = false },
		scratch = {
			-- scratchはプロジェクト共通で利用する
			filekey = {
				cwd = false, -- 作業ディレクトリを無視
				branch = false, -- Gitブランチを無視
				count = true, -- カウントは使用(異なる番号で複数作成可能)
			},
			win = { style = "float" },
		},
		scroll = { enabled = false },
		statuscolumn = { enabled = false },
		words = { enabled = false },
	},
	keys = {
		--prefix `<Leader>w` ではない特殊キーのタイプ
		-- ファイル一覧を表示
		{
			"<Leader>p",
			function()
				require("snacks").picker.files()
			end,
			desc = "Snacks: Find Files",
		},
		--キー登録したコマンドパレットを表示
		--
		-- 以下はtelescopeでの対応だが、同様の操作でsnacksで対応
		-- ただしカーソル位置が⭐の前になっており完全ではない。
		-- see: <https://blog.atusy.net/2022/11/03/telescope-as-command-pallete/>
		{
			"<Leader>P",
			function()
				require("snacks").picker.keymaps()
				vim.cmd("normal! i⭐︎")
			end,
			desc = "⭐︎Snacks: Keymaps",
		},
		{
			"<Leader>wb",
			function()
				require("snacks").picker.buffers()
			end,
			desc = "Snacks: Buffers",
		},
		{
			"<Leader>wc",
			function()
				require("snacks").picker.pickers()
			end,
			desc = "Snacks: Pickers",
		},
		{
			"<Leader>wC",
			function()
				require("snacks").picker.commands()
			end,
			desc = "Snacks: Commands",
		},
		{
			"<Leader>wd",
			function()
				require("snacks").picker.lsp_definitions()
			end,
			desc = "Snacks: Goto Definition",
		},
		{
			"<Leader>gD",
			function()
				require("snacks").picker.lsp_declarations()
			end,
			desc = "Snacks: Goto Declaration",
		},
		{
			"<Leader>we",
			function()
				require("snacks").explorer.open()
			end,
			desc = "⭐︎Snacks: Open explorer",
		},
		{
			"<Leader>wf",
			find_files_in_current_folder,
			desc = "⭐︎Snacks: Find files on current buffer folder",
		},
		{
			"<Leader>wE",
			function()
				require("snacks").explorer.reveal({})
			end,
			desc = "Snacks: Reveals the given file/buffer or the current buffer in the explorer",
		},
		{
			"<Leader>wg",
			function()
				require("snacks").lazygit.open({})
			end,
			desc = "⭐︎Snacks: Open layzgit",
		},
		{
			"<Leader>wG",
			function()
				require("snacks").picker.git_files()
			end,
			desc = "Snacks: Find Git Files",
		},
		{
			"<Leader>wh",
			function()
				require("snacks").picker.search_history()
			end,
			desc = "Snacks: Search History",
		},
		{
			"<Leader>wi",
			function()
				require("snacks").picker.lsp_implementations()
			end,
			desc = "Snacks: Goto Implementation",
		},
		{
			"<Leader>wm",
			function()
				require("snacks").picker.marks()
			end,
			desc = "Snacks: Marks",
		},
		{
			"<Leader>wn",
			function()
				require("snacks").picker.notifications()
			end,
			desc = "Snacks: Notification History",
		},
		{
			"<Leader>wo",
			function()
				require("snacks").picker.lsp_symbols()
			end,
			desc = "Snacks: LSP Buffer Symbols",
		},
		{
			"<Leader>wO",
			function()
				require("snacks").picker.lsp_workspace_symbols()
			end,
			desc = "Snacks: LSP Workspace Symbols",
		},
		{
			"<Leader>wr",
			function()
				require("snacks").picker.lsp_references()
			end,
			nowait = true,
			desc = "Snacks: References",
		},
		{
			"<Leader>wR",
			function()
				require("snacks").picker.resume()
			end,
			desc = "Snacks: Resume",
		},
		{
			-- どのようなファイルであってもメモ用のmarkdownファイルを開く
			"<Leader>ws",
			function()
				require("snacks").scratch({ ft = "markdown" })
			end,
			desc = "⭐︎Snacks: Toggle Scratch Buffer",
		},
		{
			"<Leader>wS",
			function()
				require("snacks").scratch.select()
			end,
			desc = "Snacks: Select Scratch Buffer",
		},
		{
			"<Leader>wt", -- error -> Trouble
			function()
				require("snacks").picker.diagnostics_buffer()
			end,
			desc = "Snacks: Buffer Diagnostics",
		},
		{
			"<Leader>wT", -- error -> Trouble
			function()
				require("snacks").picker.diagnostics()
			end,
			desc = "Snacks: Diagnostics",
		},
		{
			"<Leader>wy",
			function()
				require("snacks").picker.lsp_type_definitions()
			end,
			desc = "Snacks: Goto T[y]pe Definition",
		},
		{
			"<Leader>w/",
			function()
				require("snacks").picker.grep()
			end,
			desc = "Snacks: Grep",
		},
		{
			"<Leader>w*",
			function()
				require("snacks").picker.grep_word()
			end,
			desc = "Snacks: Visual selection or word",
			mode = { "n", "x" },
		},
		{
			"<Leader>w:",
			function()
				require("snacks").picker.command_history()
			end,
			desc = "Snacks: Command History",
		},
		{
			"<Leader>w<space>",
			function()
				require("snacks").picker.smart()
			end,
			desc = "⭐︎Snacks: Smart Find Files",
		},
	},
}
