-- Telescope.nvimの設定
--
-- fuzzy finder
-- TelescopeとTelescope拡張機能を管理する。
-- 利用例:
-- - `Ctrl + p`: ファイル一覧の表示
-- - `Ctrl + P`: 登録コマンドの一覧表示
-- - プレビュー画面の移動: `Ctrl + u`, `Ctrl + d`

-- name_typeで指定した形式でファイルパスを挿入する
--
-- e.g. `:t:r`でファイル名のみを挿入: `path/to/file.txt` -> `file`
-- e.g. `:.`で相対パスを挿入: `path/to/file.txt` -> `path/to/file.txt`
local function actionsInsertFilepath(prompt_bufnr, name_type)
	local actions = require("telescope.actions")
	local selection = require("telescope.actions.state").get_selected_entry()
	local file_path = vim.fn.fnamemodify(selection.path, name_type)
	actions.close(prompt_bufnr)
	vim.api.nvim_put({ file_path }, "c", false, true)
end

-- filenameのみを挿入する
local insert_filename_without_suffix = function(prompt_bufnr)
	actionsInsertFilepath(prompt_bufnr, ":t:r")
end

-- 相対パスを挿入する
local insert_relative_path = function(prompt_bufnr)
	actionsInsertFilepath(prompt_bufnr, ":.")
end

return {
	-- Telescope本体
	-- see: <https://github.com/nvim-telescope/telescope.nvim>
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		-- branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			local set = vim.keymap.set
			local builtin = require("telescope.builtin")

			require("telescope").setup({
				defaults = {
					vimgrep_arguments = {
						"rg",
						"--color=never", -- 色付けしない
						"--no-heading", -- ファイル名をマッチした行と一緒に表示
						"--with-filename", -- 常にファイル名を表示
						"--line-number", -- 行番号を表示
						"--column", -- カラム位置も表示。 `ファイル名:行:カラム`
						"--smart-case",
						-- "--no-ignore", -- ignoreは無視する
						"--hidden", -- 隠しファイルも対象
					},
					mappings = {
						i = {
							["<C-i>"] = insert_filename_without_suffix,
							["<C-r>"] = insert_relative_path,
							["<C-t>"] = function()
								require("trouble").open_with_trouble()
							end,
							-- vscodeでファイルを開く
							["<C-o>"] = function(prompt_bufnr)
								if vim.fn.executable("code") == 0 then
									vim.notify("code command not found.")
									return
								end

								local actions = require("telescope.actions")
								local selection = require("telescope.actions.state").get_selected_entry()
								local file_path = vim.fn.fnamemodify(selection.path, "%:p")

								actions.close(prompt_bufnr)
								vim.fn.jobstart({ "code", file_path }, { detach = true })
							end,
							-- ファイル名をコピーする
							["<C-w>"] = function(prompt_bufnr)
								if vim.fn.executable("code") == 0 then
									vim.notify("code command not found.")
									return
								end

								local actions = require("telescope.actions")
								local selection = require("telescope.actions.state").get_selected_entry()
								vim.notify(selection.path)
								local file_path = vim.fn.fnamemodify(selection.path, ":t:r")
								vim.notify(file_path)

								actions.close(prompt_bufnr)
								vim.fn.setreg("+", file_path)
							end,
						},
						n = {
							["<C-i>"] = insert_filename_without_suffix,
							["<C-r>"] = insert_relative_path,
							["<C-t>"] = function()
								require("trouble").open_with_trouble()
							end,
						},
					},
				},
			})

			-- colorscheme
			set("n", "<Plug>(telescope.colorscheme)", builtin.colorscheme, { desc = "Telescope: Color scheme." })
			set(
				"n",
				"<Plug>(telescope.quickfix)",
				builtin.quickfix,
				{ desc = "Telescope: Lists items in the quickfix list." }
			)

			-- quickfix and location list
			set(
				"n",
				"<Plug>(telescope.quickfixhistory)",
				builtin.quickfixhistory,
				{ desc = "Telescope: Lists all quickfix lists in your history." }
			)
			set(
				"n",
				"<Plug>(telescope.loclist)",
				builtin.loclist,
				{ desc = "Telescope: Lists items from the current window's location list." }
			)

			-- others
			set("n", "<Plug>(telescope.jumplist)", builtin.jumplist, { desc = "Telescope: Lists jump list entries." })
			set(
				"n",
				"<Plug>(telescope.spell_suggest)",
				builtin.spell_suggest,
				{ desc = "Telescope: Lists spelling suggestions for the current word under the cursor." }
			)
			set(
				"n",
				"<Plug>(telescope.filetypes)",
				builtin.filetypes,
				{ desc = "Telescope: Lists all available filetypes." }
			)

			set("n", "<Plug>(telescope.git_commits)", builtin.git_commits, { desc = "Telescope: git commits." })
			set(
				"n",
				"<Plug>(telescope.git_bcommits)",
				builtin.git_bcommits,
				{ desc = "Telescope: Lists buffer's git commits." }
			)
			set("n", "<Plug>(telescope.git_status)", builtin.git_status, { desc = "Telescope: git status." })
			set("n", "<Plug>(telescope.help_tags)", builtin.help_tags, { desc = "Telescope: Help." })
			set("n", "<Plug>(telescope.oldfiles)", builtin.oldfiles, { desc = "Telescope: Open file from history." })
			set("n", "<Plug>(telescope.registers)", builtin.registers, { desc = "Telescope: Show registers." })
			set("n", "<Plug>(telescope.vim_options)", builtin.vim_options, { desc = "Telescope: Show vim options." })
			-- TelescopeでLSPコマンド
			set(
				"n",
				"<Plug>(telescope.show_referneces)",
				builtin.lsp_references,
				{ desc = "Telescope: Show lsp referneces." }
			)
			set("n", "<Plug>(telescope.show_definitions_hsplit)", function()
				builtin.lsp_definitions({ jump_type = "split" })
			end, { desc = "⭐︎Telescope: Show lsp definitions using horizontal split." })
			set("n", "<Plug>(telescope.show_definitions_vsplit)", function()
				builtin.lsp_definitions({ jump_type = "vsplit" })
			end, { desc = "⭐︎Telescope: Show lsp definitions using vertical split." })
		end,
	},
	-- Telescopeのファイルブラウザ拡張
	-- see: <https://github.com/nvim-telescope/telescope-file-browser.nvim>
	{
		"nvim-telescope/telescope-file-browser.nvim",
		event = { "VimEnter" },
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("telescope").load_extension("file_browser")
		end,
	},
	-- TelescopeのLuasnip拡張
	-- see: <https://github.com/benfowler/telescope-luasnip.nvim>
	{
		"benfowler/telescope-luasnip.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("telescope").load_extension("luasnip")
		end,
	},
	-- Telescopeでdfzfを利用する拡張
	-- 検索速度が早くなる
	-- see: <https://github.com/nvim-telescope/telescope-fzf-native.nvim>
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		build = "make",
		config = function()
			require("telescope").load_extension("fzf")
		end,
	},
}
