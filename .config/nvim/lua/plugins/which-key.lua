-- folke/which-key.nvim
-- see: <https://github.com/folke/which-key.nvim>
--
-- ショートカットキーのコマンドパレット
--
-- ショートカットキーに登録するときの簡易ルール
-- - descriptionには、"⭐︎"を付けることでTelescopeで検索した時に優先して表示される。

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

-- cluade codeコマンドのターミナルを開閉
--
-- dependencies: `akinsho/toggleterm.nvim`
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
--
-- dependencies: `akinsho/toggleterm.nvim`
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
--
-- dependencies: `akinsho/toggleterm.nvim`
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
-- dependencies: `akinsho/toggleterm.nvim`
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

-- Buffer関連のキー登録
local function registerBufferKey()
	require("which-key").add({
		{ "<Leader>b", group = "Buffer" },
		{ "<Leader>bl", require("telescope.builtin").buffers, desc = "⭐︎Telescope: Open buffer list." },
		{
			"<Leader>b/",
			require("telescope.builtin").current_buffer_fuzzy_find,
			desc = "⭐︎Telescope: Live fuzzy search inside of the currently open buffer.",
		},
		{ "<Leader>bz", group = "Fold" },
		{ "<Leader>bza", "za", desc = "Fold: Toggle under the cursor." },
		{ "<Leader>bzA", "zA", desc = "Fold: Toggle all under the cursor." },
		{ "<Leader>bzc", "zc", desc = "⭐︎Fold: Close under the cursor." },
		{ "<Leader>bzC", "zC", desc = "⭐︎Fold: Close all under the cursor." },
		{ "<Leader>bzm", "zm", desc = "Fold: Close in Window." },
		{ "<Leader>bzM", "zM", desc = "⭐︎Fold: Close all in Window." },
		{ "<Leader>bzo", "zo", desc = "⭐︎Fold: Open under the cursor." },
		{ "<Leader>bzO", "zO", desc = "⭐︎Fold: Open all under the cursor." },
		{ "<Leader>bzr", "zr", desc = "Fold: Open in Window." },
		{ "<Leader>bzR", "zR", desc = "⭐︎Fold: Open all in Window." },
	})
end

-- コマンド関連のキー登録
local function registerCommandKey()
	require("which-key").add({
		{ "<Leader>c", group = "Commands" },
		{ "<Leader>cl", require("telescope.builtin").commands, desc = "⭐︎Telescope: Open command list." },
		{
			"<Leader>ch",
			require("telescope.builtin").command_history,
			desc = "⭐︎Telescope: Open command history list.",
		},
	})
end

-- VSCodeのコマンドパレットと合わせるためのショートカットキー登録
local function registerCommandPalletKey()
	require("which-key").add({
		-- ファイル一覧を表示
		{
			"<Leader>p",
			"<cmd>Telescope find_files find_command=rg,--files,--hidden,--glob,!*.git<CR>",
			desc = "⭐︎Telescope: Find files.",
		},
		--キー登録したコマンドパレットを表示
		-- see: <https://blog.atusy.net/2022/11/03/telescope-as-command-pallete/>
		{
			"<Leader>P",
			function()
				require("telescope.builtin").keymaps()
				vim.cmd("normal! i⭐︎")
			end,
			desc = "⭐︎Telescope: Open command palet(keymaps).",
		},
	})
end

-- 編集に関連するキー登録
--
-- linter, formatterについても、ここに記載している。
local function registerEditKey()
	-- formatの実行関数
	local function format(opts)
		opts = vim.tbl_extend("keep", opts or {}, { lsp_fallback = true, async = false, timeout_ms = 1000 })
		require("conform").format(opts)
	end

	require("which-key").add({
		{ "<Leader>e", group = "Edit" },
		-- Toggle auto save.
		-- dependencies: `okuuva/auto-save.nvim`
		{ "<Leader>ea", "<cmd>ASToggle<CR>", desc = "AutoSave: Toggle auto save mode." },
		{ "<Leader>ec", group = "Conform" },
		{ "<Leader>ecd", group = "Disable" },
		{
			"<Leader>ecdb",
			function()
				vim.b.disable_autoformat = true
			end,
			desc = "Conform: Disable for this buffer.",
		},
		{
			"<Leader>ecdg",
			function()
				vim.g.disable_autoformat = true
			end,
			desc = "Conform: Disable.",
		},
		{ "<Leader>ece", group = "Enable" },
		{
			"<Leader>eceb",
			function()
				vim.b.disable_autoformat = false
			end,
			desc = "⭐︎Conform: Enable for this buffer.",
		},
		{
			"<Leader>eceg",
			function()
				vim.g.disable_autoformat = false
			end,
			desc = "Conform: Enable",
		},
		{ "<Leader>eci", "<cmd>ConformInfo<CR>", desc = "⭐︎Conform: Show information." },
		{ "<Leader>ef", group = "Format" },
		{ "<Leader>eff", format, desc = "⭐︎Conform: Format file or range." },
		{
			"<Leader>efs",
			function()
				vim.ui.input({ prompt = "Formatter: " }, function(formatter)
					format({ formatters = { formatter } })
				end)
			end,
			desc = "⭐︎Conform: Specific formatter.",
		},
		-- dependencies: `mfussenegger/nvim-lint`
		{
			"<Leader>el",
			function()
				require("lint").try_lint()
			end,
			desc = "⭐︎Lint: Trigger linting for current file",
		},
		-- dependencies: `benfowler/telescope-luasnip.nvim`
		{ "<Leader>es", "<cmd>Telescope luasnip<CR>", desc = "⭐︎Telescope Luasnip: Open snippet list." },
	})
end

-- File関連のキー登録
local function registerFileKey()
	-- 指定した値をクリップボードにコピーする
	local function copyToClipboard(value)
		--  zellijからnvimを利用するとチラつくケースがあったので修正
		-- vim.notify("Copied: " .. value)
		vim.fn.setreg("+", value)
	end

	require("which-key").add({
		{ "<Leader>f", group = "File" },
		-- Open file browser.
		-- dependencies: `nvim-telescope/telescope-file-browser.nvim`
		{ "<Leader>fb", "<cmd>Telescope file_browser<CR>", desc = "⭐︎Telescope FileBrowser: Open." },
		{ "<Leader>fc", group = "Copy file path" },
		{
			"<Leader>fca",
			function()
				copyToClipboard(vim.fn.expand("%:p"))
			end,
			desc = "Self: Copy absolute file path.",
		},
		{
			"<Leader>fch",
			function()
				copyToClipboard(vim.fn.expand("%:~"))
			end,
			desc = "Self: Copy relative filepath from home.",
		},
		{
			"<Leader>fcn",
			function()
				copyToClipboard(vim.fn.expand("%:t"))
			end,
			desc = "⭐︎Self: Copy file name.",
		},
		{
			"<Leader>fcr",
			function()
				copyToClipboard(vim.fn.expand("%:."))
			end,
			desc = "⭐︎Self: Copy relative file path.",
		},
		{
			"<Leader>fcw",
			function()
				copyToClipboard(vim.fn.expand("%:t:r"))
			end,
			desc = "⭐︎Self: Copy file name without suffix.",
		},
		{
			"<Leader>ft",
			function()
				local filepath = vim.fn.tempname()
				vim.cmd("edit " .. filepath)
			end,
			desc = "⭐︎Zettelkasten: Create and open temporary file.",
		},
		{ "<Leader>fv", vifmToggle, desc = "⭐︎ToggleTerm: Open vifm." },
	})
end

-- Git関連のキー登録
--
-- dependencies:
-- - `sindrets/diffview.nvim`
-- - `pwntester/octo.nvim`
local function registerGitKey()
	require("which-key").add({
		{ "<Leader>g", group = "Git" },
		{ "<Leader>ga", ghDashToggle, desc = "⭐︎ToggleTerm: Open gh dash." },
		{ "<Leader>gd", group = "Diff" },
		{ "<Leader>gdf", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview: Open file history." },
		{ "<Leader>gdo", "<cmd>DiffviewOpen<CR>", desc = "Diffview: Open diffview." },
		{ "<Leader>ge", group = "Edit issue/PR" },
		{ "<Leader>gec", group = "Comment" },
		{ "<Leader>geca", "<cmd>Octo comment add<CR>", mode = { "n", "v" }, desc = "⭐︎Octo: Add a new comment." },
		{ "<Leader>gecd", "<cmd>Octo comment delete<CR>", desc = "⭐︎Octo: Delete a comment." },
		{ "<Leader>get", group = "Thread" },
		{ "<Leader>getr", "<cmd>Octo thread resolve<CR>", desc = "⭐︎Octo: Resolve a review thread." },
		{ "<Leader>geto", "<cmd>Octo thread unresolve<CR>", desc = "Octo: Unresolve a review thread." },
		{ "<Leader>gi", group = "GitHub Issue" },
		{ "<Leader>gil", "<cmd>Octo issue list<CR>", desc = "⭐︎Octo: List issues." },
		{ "<Leader>gio", "<cmd>Octo issue rowser<CR>", desc = "Octo: Open current issue in the browser." },
		{ "<Leader>gir", "<cmd>Octo issue reload<CR>", desc = "Octo: Reload issue." },
		{
			"<Leader>giu",
			"<cmd>Octo issue url<CR>",
			desc = "Octo: Copies the URL of the current issue to the system clipboard.",
		},
		{ "<Leader>gi/", "<cmd>Octo issue search<CR>", desc = "Octo: Live issue search." },
		{ "<Leader>gh", group = "Hunk" },
		{ "<Leader>ghb", group = "Blame" },
		{
			"<Leader>ghbe",
			function()
				require("gitsigns").blame_line({ full = true })
			end,
			desc = "GitSigns: Blame line.",
		},
		{
			"<Leader>ghbt",
			function()
				require("gitsigns").toggle_current_line_blame()
			end,
			desc = "GitSigns: Toggle line blame.",
		},
		{ "<Leader>ghD", group = "Diff" },
		{
			"<Leader>ghDd",
			function()
				require("gitsigns").diffthis()
			end,
			desc = "GitSigns: Diff this.",
		},
		{
			"<Leader>ghDD",
			function()
				require("gitsigns").diffthis("~")
			end,
			desc = "GitSigns: Diff this (against HEAD~).",
		},
		{
			"<Leader>ghDw",
			"<cmd>Gitsign toggle_word_diff<CR>",
			desc = "GitSigns: Toggle word diff.",
		},
		{
			"<Leader>ghn",
			function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					require("gitsigns").nav_hunk("next")
				end
			end,
			desc = "GitSigns: Next hunk.",
		},
		{
			"<Leader>ghp",
			function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					require("gitsigns").nav_hunk("prev")
				end
			end,
			desc = "GitSigns: Next hunk.",
		},
		{
			"<Leader>ghq",
			"<cmd>Gitsign setqflist<CR>",
			desc = "GitSigns: Show hunks quickfix list.",
		},
		{
			"<Leader>ghr",
			function()
				require("gitsigns").reset_hunk()
			end,
			desc = "GitSigns: Reset hunk.",
			mode = { "n", "v" },
		},
		{
			"<Leader>ghR",
			function()
				require("gitsigns").reset_buffer()
			end,
			desc = "GitSigns: Reset buffer.",
		},
		{
			"<Leader>ghs",
			function()
				require("gitsigns").stage_hunk()
			end,
			desc = "GitSigns: Stage hunk.",
			mode = { "n" },
		},
		{
			"<Leader>ghs",
			function()
				require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end,
			desc = "GitSigns: Stage hunk.",
			mode = { "v" },
		},
		{
			"<Leader>ghS",
			function()
				require("gitsigns").stage_buffer()
			end,
			desc = "GitSigns: Stage buffer.",
		},
		{
			"<Leader>ghv",
			function()
				require("gitsigns").preview_hunk()
			end,
			desc = "GitSigns: Preview hunk.",
		},
		{
			"<Leader>ghv",
			function()
				require("gitsigns").preview_hunk()
			end,
			desc = "GitSigns: Preview hunk inline.",
		},
		{ "<Leader>gg", "<cmd>Octo gist list<CR>", desc = "Octo: List user gists." },
		{ "<Leader>gl", lazygitToggle, desc = "⭐︎ToggleTerm: Open lazygit." },
		{ "<Leader>gp", group = "Pull request" },
		{ "<Leader>gpc", "<cmd>Octo pr checkout<CR>", desc = "⭐︎Octo: Checkout PR." },
		-- Show PR review.
		-- PR Review用に分岐元との差分を表示
		-- see: <https://github.com/sindrets/diffview.nvim/blob/main/USAGE.md>
		{ "<Leader>gpd", group = "Diff" },
		{
			"<Leader>gpdb",
			function()
				vim.ui.input({ prompt = "Enter base branch name: " }, function(branch_name)
					local base_hash = vim.fn.system("git merge-base " .. branch_name .. " HEAD")
					vim.cmd("DiffviewOpen " .. base_hash .. " ...HEAD --imply-local")
				end)
			end,
			desc = "Diffview: PR for specific branch.",
		},
		{
			"<Leader>gpdl",
			"<cmd>DiffviewFileHistory --range=origin/HEAD...HEAD --right-only --no-merges<CR>",
			desc = "Diffview: Open large PR.",
		},
		{
			"<Leader>gpdo",
			"<cmd>DiffviewOpen origin/HEAD...HEAD --imply-local<CR>",
			desc = "⭐︎Diffview: Open PR.",
		},
		{ "<Leader>gpdt", "<cmd>Octo pr diff<CR>", desc = "Octo: Show PR diff." },
		{ "<Leader>gph", "<cmd>Octo pr checks<CR>", desc = "Octo: Show the status of all checks run on the PR." },
		{ "<Leader>gpl", "<cmd>Octo pr list<CR>", desc = "⭐︎Octo: List PRs." },
		{ "<Leader>gpm", "<cmd>Octo pr commits<CR>", desc = "Octo: List all PR commits." },
		{ "<Leader>gpn", "<cmd>Octo pr reload<CR>", desc = "Octo: Reload PR." },
		{ "<Leader>gpo", "<cmd>Octo pr browser<CR>", desc = "Octo: Open current PR in the browser." },
		{ "<Leader>gpr", group = "Review" },
		{ "<Leader>gprb", "<cmd>Octo review submit<CR>", desc = "⭐︎Octo: Submit the review." },
		{ "<Leader>gprc", "<cmd>Octo review comments<CR>", desc = "⭐︎Octo: View pending review comments." },
		{
			"<Leader>gprd",
			"<cmd>Octo review discard<CR>",
			desc = "Octo: Deletes a pending review for current PR if any.",
		},
		{
			"<Leader>gprq",
			"<cmd>Octo review close<CR>",
			desc = "⭐︎Octo: Close the review window and return to the PR.",
		},
		{
			"<Leader>gprr",
			"<cmd>Octo review resume<CR>",
			desc = "⭐︎Octo: Edit a pending review for current PR.",
		},
		{ "<Leader>gprs", "<cmd>Octo review start<CR>", desc = "⭐︎Octo: Start a new review." },
		{
			"<Leader>gpu",
			"<cmd>Octo pr url<CR>",
			desc = "Octo: Copies the URL of the current PR to the system clipboard.",
		},
		{ "<Leader>gp/", "<cmd>Octo pr search<CR>", desc = "Octo: Live PR search." },
		{ "<Leader>gr", group = "Repository" },
		{ "<Leader>grb", "<cmd>Octo repo browser<CR>", desc = "Octo: Open current repo in the browser." },
		{
			"<Leader>gru",
			"<cmd>Octo repo url<CR>",
			desc = "Octo: Copies the URL of the current repository to the system clipboard.",
		},
	})
end

-- 言語関連のキー登録
--
-- 先頭は言語を分けるためのプレフィックスとして利用する
-- "l"は予約済みのため、二文字目の"a"を利用する。
local function registerLanguageKey()
	require("which-key").add({
		{ "<Leader>a", group = "Language" },
		{ "<Leader>am", group = "Markdown" },
		{
			"<Leader>amb",
			function()
				require("markdown-hop-links").frontMatterPicker()
			end,
			desc = "⭐︎MarkdownLinkHops: Show backlinks.",
		},
		{ "<Leader>aml", group = "Auto lastmod" },
		{ "<Leader>amlb", group = "Buffer" },
		{
			"<Leader>amlbd",
			require("auto-lastmod").disable_buffer,
			desc = "⭐︎AutoLastMod: Disable auto-lastmod",
		},
		{ "<Leader>amlbe", require("auto-lastmod").enable_buffer, desc = "AutoLastMod: Enable auto-lastmod" },
		{ "<Leader>amlg", group = "Global" },
		{
			"<Leader>amlgd",
			require("auto-lastmod").disable_global,
			desc = "⭐︎AutoLastMod: Disable auto-lastmod",
		},
		{ "<Leader>amlge", require("auto-lastmod").enable_global, desc = "AutoLastMod: Enable auto-lastmod" },
		{ "<Leader>amf", group = "Front matter" },
		{
			"<Leader>amfc",
			function()
				vim.ui.input({ prompt = "Category: " }, function(category)
					require("front-matter-searcher").frontMatterPicker({
						select_query = 'select(.categories[]? == "' .. category .. '")',
					})
				end)
			end,
			desc = "⭐︎FrontMatterSearcher: Search by Category.",
		},
		{
			"<Leader>amfg",
			function()
				vim.ui.input({ prompt = "Tag: " }, function(tag)
					require("front-matter-searcher").frontMatterPicker({
						select_query = 'select(.tags[]? == "' .. tag .. '")',
					})
				end)
			end,
			desc = "⭐︎FrontMatterSearcher: Search by tag.",
		},
		{
			"<Leader>amft",
			function()
				require("front-matter-searcher").frontMatterPicker()
			end,
			desc = "⭐︎FrontMatterSearcher: Search by title.",
		},
		-- dependencies: `iamcco/markdown-preview.nvim`
		{ "<Leader>amp", group = "Preview" },
		{ "<Leader>amps", "<cmd>MarkdownPreview<CR>", desc = "⭐︎MarkdownPreview: Start." },
		{ "<Leader>ampq", "<cmd>MarkdownPreviewStop<CR>", desc = "MarkdownPreview: Stop." },
		{ "<Leader>amt", group = "Timestamp" },
		{
			"<Leader>amtd",
			function()
				local ti = require("timestamp-inserter")
				vim.api.nvim_put({ ti.timestamp2DateStr(ti.getNowEpoch()) }, "c", true, true)
			end,
			desc = "⭐︎TimestampInserter: Insert current date.",
		},
		{
			"<Leader>amtf",
			function()
				local ti = require("timestamp-inserter")
				vim.api.nvim_put({ ti.timestamp2DateTimeStr(ti.getNowEpoch()) }, "c", true, true)
			end,
			desc = "TimestampInserter: Insert current date and time.",
		},
		{
			"<Leader>amtt",
			function()
				local ti = require("timestamp-inserter")
				vim.api.nvim_put({ ti.timestamp2TimeStr(ti.getNowEpoch()) }, "c", true, true)
			end,
			desc = "⭐︎TimestampInserter: Insert current time.",
		},
		{ "<Leader>amve", "<cmd>RenderMarkdown enable<CR>", desc = "⭐︎RenderMarkdown: Enable." },
		{ "<Leader>amvd", "<cmd>RenderMarkdown disable<CR>", desc = "⭐︎RenderMarkdown: Disable." },
		{ "<Leader>ar", group = "REST" },
		{
			"<Leader>ara",
			function()
				require("kulala").run_all()
			end,
			desc = "Kulala: Send all requests.",
		},
		{
			"<Leader>arb",
			function()
				require("kulala").scratchpad()
			end,
			desc = "Kulala: Open scratchpad.",
		},
		{
			"<Leader>arc",
			function()
				require("kulala").copy()
			end,
			mode = { "n", "v" },
			desc = "Kulala: Copy as curl.",
		},
		{
			"<Leader>arC",
			function()
				require("kulala").from_curl()
			end,
			mode = { "n", "v" },
			desc = "Kulala: Paste from curl.",
		},
		{
			"<Leader>are",
			function()
				require("kulala").set_selected_env()
			end,
			mode = { "n" },
			desc = "Kulala: Select env.",
		},
		{
			"<Leader>arf",
			function()
				require("kulala").search()
			end,
			mode = { "n" },
			desc = "Kulala: Find request.",
		},
		{
			"<Leader>ari",
			function()
				require("kulala").inspect()
			end,
			mode = { "n" },
			desc = "Kulala: Inspect curl request.",
		},
		{
			"<Leader>arn",
			function()
				require("kulala").jump_next()
			end,
			mode = { "n" },
			desc = "Kulala: Jump to next request.",
		},
		{
			"<Leader>arp",
			function()
				require("kulala").jump_prev()
			end,
			mode = { "n" },
			desc = "Kulala: Jump to previous request.",
		},
		{
			"<leader>arr",
			function()
				require("kulala").replay()
			end,
			mode = { "n" },
			desc = "Kulala: Replay the last request",
		},
		{
			"<leader>ars",
			function()
				require("kulala").run()
			end,
			mode = { "n", "v" },
			desc = "Kulala: Send request",
		},
		{
			"<leader>arx",
			function()
				require("kulala").scripts_clear_global()
			end,
			mode = { "n" },
			desc = "Kulala: Clear globals",
		},
		{
			"<leader>arX",
			function()
				require("kulala").clear_cached_files()
			end,
			mode = { "n" },
			desc = "Kulala: Clear cached files",
		},
		{ "<Leader>at", group = "Test" },
		{
			"<Leader>atl",
			function()
				require("neotest").run.run_last()
			end,
			desc = "Neotest: Run test last.",
		},
		{
			"<Leader>atn",
			function()
				require("neotest").run.run()
			end,
			desc = "Neotest: Run test nearest.",
		},
		{
			"<Leader>atO",
			function()
				require("neotest").output_panel.toggle()
			end,
			desc = "Neotest: Toggl test output panel.",
		},
		{
			"<Leader>ato",
			function()
				require("neotest").output.open({ enter = true, auto_close = true })
			end,
			desc = "Neotest: Test output.",
		},
		{
			"<Leader>ats",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Neotest: Toggle test summary.",
		},
		{
			"<Leader>att",
			function()
				require("neotest").run.stop()
			end,
			desc = "Neotest: Test terminate.",
		},
	})
end

-- LSPとLLMに関連するキー登録
--
-- dependencies: `CopilotC-Nvim/CopilotChat.nvim`
local function registerLspAndLlmKey()
	-- Normal mode
	require("which-key").add({
		{ "<Leader>l", group = "LSP and LLM" },
		{ "<Leader>la", group = "Avante" },
		{
			"<Leader>laa",
			"<cmd>AvanteAsk<CR>",
			desc = "Avante: Ask mode.",
			mode = { "n", "v" },
		},
		{
			"<Leader>lae",
			"<cmd>AvanteEdit<CR>",
			desc = "Avante: Edit mode.",
			mode = { "n", "v" },
		},
		{
			"<Leader>laf",
			"<cmd>AvanteFocus<CR>",
			desc = "Avante: Switch focus to/from the sidebar.",
			mode = { "n" },
		},
		{
			"<Leader>lag",
			"<cmd>AvanteToggle<CR>",
			desc = "Avante: Toggle the sidebar.",
			mode = { "n", "v" },
		},
		{
			"<Leader>lah",
			"<cmd>AvanteHistory<CR>",
			desc = "Avante: Show history.",
			mode = { "n" },
		},
		{
			"<Leader>lam",
			"<cmd>AvanteModels<CR>",
			desc = "Avante: Select model.",
			mode = { "n" },
		},
		{ "<Leader>las", group = "Avante providers" },
		{
			"<Leader>lasc",
			"<cmd>AvanteSwitchProvider copilot_claude<CR>",
			desc = "Avante: Switch provider to GitHub Copilot Calude.",
			mode = { "n" },
		},
		{
			"<Leader>lasg",
			"<cmd>AvanteSwitchProvider copilot_gpt<CR>",
			desc = "Avante: Switch provider to GitHub Copilot GPT.",
			mode = { "n" },
		},
		{
			"<Leader>lat",
			"<cmd>AvanteStop<CR>",
			desc = "Avante: Stop the current AI request.",
			mode = { "n" },
		},
		{ "<Leader>lc", group = "GitHub Copilot Chat" },
		{
			"<Leader>lcc",
			function()
				require("CopilotChat").close()
			end,
			desc = "CopilotChat: Close chat window.",
		},
		{
			"<Leader>lci",
			function()
				require("CopilotChat").toggle({
					window = {
						layout = "float",
						title = "CopilotChat - Inline Chat",
						relative = "cursor",
						width = 1,
						height = 0.4,
						row = 1,
					},
				})
			end,
			desc = "⭐︎CopilotChat: Inline chat",
		},
		{ "<Leader>lco", "<cmd>CopilotChatOpen<CR>", desc = "⭐︎CopilotChat: Open chat window." },
		{
			"<Leader>lcq",
			function()
				vim.ui.input({ prompt = "Quick Chat: " }, function(text)
					if text ~= "" then
						require("CopilotChat").ask(text, { selection = require("CopilotChat.select").buffer })
					end
				end)
			end,
			desc = "⭐︎CopilotChat: Quick chat",
		},
		{
			"<Leader>lcq",
			function()
				local input = vim.fn.input("Quick Chat: ")
				if input ~= "" then
					require("CopilotChat").ask(input, { selection = require("CopilotChat.select").visual })
				end
			end,
			desc = "⭐︎CopilotChat: Quick chat",
			mode = { "v" },
		},
		{
			"<Leader>lcr",
			function()
				require("CopilotChat").reset()
			end,
			desc = "CopilotChat: Reset chat window.",
		},
		-- `<Leader>le`はLSPのtelescope利用版で利用済み
		{ "<Leader>lg", group = "GitHub Copilot" },
		{ "<Leader>lge", "<cmd>Copilot enable<CR>", desc = "Copilot: Enable." },
		{ "<Leader>lgd", "<cmd>Copilot disable<CR>", desc = "Copilot: Disable." },
		{ "<Leader>lgi", "<cmd>Copilot signin<CR>", desc = "Copilot: Signin." },
		{ "<Leader>lgo", "<cmd>Copilot signout<CR>", desc = "Copilot: Signout." },
		{ "<Leader>lgp", "<cmd>Copilot panel<CR>", desc = "Copilot: Show panel." },
		{ "<Leader>lgr", "<cmd>Copilot restart<CR>", desc = "Copilot: Restart." },
		{ "<Leader>lgs", "<cmd>Copilot status<CR>", desc = "⭐︎Copilot: Show status." },
		{ "<Leader>lgu", "<cmd>Copilot setup<CR>", desc = "Copilot: Setup." },
		-- `<Leader>ll`はLSPで利用済み
		{ "<Leader>lp", "<cmd>MCPHub<CR>", desc = "MCPHub: Open.", mode = { "n" } },
		{ "<Leader>lt", group = "Trouble" },
		{
			"<Leader>ltd",
			function()
				require("trouble").toggle("document_diagnostics")
			end,
			desc = "Trouble: Toggle document diagnostics.",
		},
		{
			"<Leader>ltl",
			function()
				require("trouble").toggle("loclist")
			end,
			desc = "Trouble: Toggle location list.",
		},
		{
			"<Leader>ltq",
			function()
				require("trouble").toggle("quickfix")
			end,
			desc = "Trouble: Toggle quickfix.",
		},
		{
			"<Leader>ltr",
			function()
				require("trouble").toggle("lsp_references")
			end,
			desc = "Trouble: Toggle LSP references.",
		},
		{
			"<Leader>ltw",
			function()
				require("trouble").toggle("workspace_diagnostics")
			end,
			desc = "Trouble: Toggle workspace diagnostics.",
		},
		{
			"<Leader>ltx",
			function()
				require("trouble").toggle()
			end,
			desc = "Trouble: Toggle.",
		},
		{ "<Leader>lu", group = "Claude" },
		{
			"<Leader>luc",
			"<cmd>ClaudeCodeContinue<CR>",
			desc = "ClaudeCode: Resume the most recent conversation.",
			mode = { "n" },
		},
		{
			"<Leader>luo",
			"<cmd>ClaudeCode<CR>",
			desc = "ClaudeCode: Open.",
			mode = { "n" },
		},
		{
			"<Leader>lur",
			"<cmd>ClaudeCodeResume<CR>",
			desc = "ClaudeCode: Display an interactive conversation picker.",
			mode = { "n" },
		},
		{ "<Leader>lut", claudeCodeToggle, desc = "⭐︎ToggleTerm: Open claude code." },
	})

	-- LspAttachしたときのみ設定を追加
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(ctx)
			-- see: <https://github.com/neovim/nvim-lspconfig?tab=readme-ov-file#suggested-configuration>
			require("which-key").add({
				{ "<Leader>le", group = "LSP with telescope" },
				{
					"<Leader>led",
					require("telescope.builtin").lsp_definitions,
					desc = "LSP Telescope: Go to definition.",
				},
				{ "<Leader>lee", group = "Diagnostics" },
				{
					"<Leader>leeb",
					function()
						require("telescope.builtin").diagnostics({ bufnr = 0 })
					end,
					desc = "LSP Telescope: Lists diagnostics for all open buffers.",
				},
				{
					"<Leader>leew",
					require("telescope.builtin").diagnostics,
					desc = "LSP Telescope: Lists diagnostics for all open buffers.",
				},
				{
					"<Leader>lei",
					require("telescope.builtin").lsp_implementations,
					desc = "LSP Telescope: Go to implementation.",
				},
				{
					"<Leader>len",
					require("telescope.builtin").lsp_incoming_calls,
					desc = "LSP Telescope: Lists LSP incoming calls.",
				},
				{
					"<Leader>leo",
					require("telescope.builtin").lsp_outgoing_calls,
					desc = "LSP Telescope: Lists LSP outgoing calls.",
				},
				{
					"<Leader>ler",
					require("telescope.builtin").lsp_references,
					desc = "LSP Telescope: Lists LSP References.",
				},
				{ "<Leader>les", group = "Document symbols" },
				{
					"<Leader>lesb",
					require("telescope.builtin").lsp_document_symbols,
					desc = "LSP Telescope: Lists LSP document symbols in the current buffer.",
				},
				{
					"<Leader>lesw",
					require("telescope.builtin").lsp_workspace_symbols,
					desc = "LSP Telescope: Lists LSP document symbols in the current workspace.",
				},
				{
					"<Leader>lesy",
					require("telescope.builtin").lsp_dynamic_workspace_symbols,
					desc = "LSP Telescope: Dynamically lists LSP for all workspace symbols.",
				},
				{
					"<Leader>let",
					require("telescope.builtin").lsp_type_definitions,
					desc = "LSP Telescope: Go to definition of the type.",
				},
				{ "<Leader>ll", group = "LSP" },
				{ "<Leader>lla", vim.lsp.buf.code_action, desc = "⭐︎LSP: Code action." },
				{ "<Leader>lld", vim.lsp.buf.definition, desc = "⭐︎LSP: Go to definition." },
				{ "<Leader>llD", vim.lsp.buf.declaration, desc = "⭐︎LSP: Go to declaration." },
				{ "<Leader>lle", group = "Diagnostic" },
				{ "<Leader>lleo", vim.diagnostic.open_float, desc = "⭐︎LSP: Show line diagnostics." },
				{ "<Leader>llep", vim.diagnostic.goto_prev, desc = "⭐︎LSP: Go to previous diagnostics." },
				{ "<Leader>llen", vim.diagnostic.goto_next, desc = "⭐︎LSP: Go to next diagnostics." },
				{ "<Leader>llel", vim.diagnostic.setloclist, desc = "⭐︎LSP: Set loclist diagnostics." },
				{
					"<Leader>llf",
					function()
						vim.lsp.buf.format({ async = true })
					end,
					desc = "⭐︎LSP: Formatting.",
				},
				{ "<Leader>lli", vim.lsp.buf.implementation, desc = "⭐︎LSP: Go to implementation." },
				{ "<Leader>llk", vim.lsp.buf.signature_help, desc = "⭐︎LSP: Show signature help." },
				{ "<Leader>llK", vim.lsp.buf.hover, desc = "⭐︎LSP: Show hover." },
				{ "<Leader>lln", vim.lsp.buf.rename, desc = "⭐︎LSP: Rename." },
				{ "<Leader>llo", "<cmd>LspRestart<CR>", desc = "⭐︎LSP: Restart lsp." },
				{ "<Leader>llr", vim.lsp.buf.references, desc = "⭐︎LSP: Show references." },
				{ "<Leader>lls", "<cmd>LspInfo<CR>", desc = "⭐︎LSP: Show lsp info." },
				{ "<Leader>llt", vim.lsp.buf.type_definition, desc = "⭐︎LSP: Type definition." },
				{ "<Leader>llw", group = "workspace" },
				{ "<Leader>llwa", vim.lsp.buf.add_workspace_folder, desc = "LSP: Add workspace folder." },
				{ "<Leader>llwr", vim.lsp.buf.remove_workspace_folder, desc = "LSP: Remove workspace folder." },
				{ "<Leader>llwl", vim.lsp.buf.list_workspace_folders, desc = "LSP: List workspace folders." },
			}, {
				buffer = ctx.buff,
			})
		end,
	})
end

-- Marks関連のキー登録
local function registerMarkKey()
	require("which-key").add({
		{ "<Leader>m", group = "Marks" },
		{ "<Leader>ml", require("telescope.builtin").marks, desc = "⭐︎Telescope: Lists vim marks." },
	})
end

-- Outline関連のキー登録
--
-- dependencies:
--   - `hedyhli/outline.nvim`
--   - `stevearc/aerial.nvim`
local function registerOutlineKey()
	require("which-key").add({
		{ "<Leader>o", group = "Outline" },
		{ "<Leader>of", "<cmd>OutlineFollow<CR>", desc = "Outline: Go follow cursor position." },
		{ "<Leader>oo", "<cmd>OutlineOpen<CR>", desc = "⭐︎Outline: Open." },
		{ "<Leader>oq", "<cmd>OutlineClose<CR>", desc = "Outline: Close." },
		{ "<Leader>os", "<cmd>OutlineStatus<CR>", desc = "Outline: Show status." },
		{ "<Leader>or", "<cmd>OutlinesRefresh<CR>", desc = "Outline: Refresh of symbols." },
		{ "<Leader>ot", "<cmd>Telescope aerial<CR>", desc = "Aerial: Open using telescope." },
	})
end

-- QuickfixとLocation関連のキー登録
local function registerQuickfixAndLocation()
	require("which-key").add({
		{ "<Leader>q", group = "Quickfix and Location list" },
		{ "<Leader>ql", group = "Location list" },
		{ "<Leader>qln", "<cmd>lnext<CR>", desc = "⭐︎Location: Next." },
		{ "<Leader>qlo", "<cmd>lopen<CR>", desc = "⭐︎Location: Open." },
		{ "<Leader>qlp", "<cmd>lprevious<CR>", desc = "⭐︎Location: Previous." },
		{ "<Leader>qlq", "<cmd>lclose<CR>", desc = "⭐︎Location: Close." },
		{ "<Leader>qq", group = "Quickfix" },
		{ "<Leader>qqn", "<cmd>cnext<CR>", desc = "⭐︎Quickfix: Next." },
		{ "<Leader>qqo", "<cmd>copen<CR>", desc = "⭐︎Quickfix: Open." },
		{ "<Leader>qqp", "<cmd>cprevious<CR>", desc = "⭐︎Quickfix: Previous." },
		{ "<Leader>qqq", "<cmd>cclose<CR>", desc = "⭐︎Quickfix: Close." },
	})
end

-- Terminal関連のキー登録
--
-- dependencies: `akinsho/toggleterm.nvim`
-- `exe v:count1 . "ToggleTerm"`では、コマンドの前に数字を設定することで任意の端末を開くことができる。
-- 数字を設定しなければ、最初の端末を開くことができきる。
local function registerTerminalAndToolsKey()
	require("which-key").add({
		{ "<Leader>t", group = "Terminal and Tools" },
		{ "<Leader>tl", "<cmd>Lazy<CR>", desc = "⭐︎Lazy: Show Lazy UI." },
		{ "<Leader>tm", group = "Mason" },
		{ "<Leader>tml", "<cmd>MasonLog<CR>", desc = "Mason: Show log." },
		{ "<Leader>tmo", "<cmd>Mason<CR>", desc = "⭐︎Mason: Show Mason UI." },
		{ "<Leader>tmu", group = "Update" },
		{ "<Leader>tmum", "<cmd>MasonUpdate<CR>", desc = "Mason: update." },
		{ "<Leader>tmut", "<cmd>MasonToolsUpdate<CR>", desc = "MasonTools: update." },
		{ "<Leader>tt", group = "Terminal" },
		{
			"<Leader>ttf",
			"<cmd>exe v:count1 . \"ToggleTerm direction='float'\"<CR>",
			desc = "⭐︎ToggleTerm: Open floating terminal.",
		},
		{
			"<Leader>tth",
			"<cmd>exe v:count1 . \"ToggleTerm direction='horizontal'\"<CR>",
			desc = "⭐︎ToggleTerm: Open horizontal terminal.",
		},
		{ "<Leader>ttn", "<cmd>ToggleTermSetName<CR>", desc = "ToggleTerm: Set a display name." },
		{ "<Leader>ttp", "<cmd>TermSelect<CR>", desc = "ToggleTerm: Select a terminal." },
		{ "<Leader>tts", group = "Send to terminal" },
		{
			"<Leader>ttsl",
			"<cmd>ToggleTermSendCurrentLine<CR>",
			desc = "ToggleTerm: Send current line to terminal.",
		},
		{
			"<Leader>ttsv",
			"<cmd>ToggleTermSendVisualLines<CR>",
			desc = "ToggleTerm: Send selected lines to terminal.",
		},
		{ "<Leader>ttss", "<cmd>ToggleTermSendVisualSelection<CR>", desc = "ToggleTerm: Send selection to terminal." },
		{
			"<Leader>ttt",
			"<cmd>exe v:count1 . \"ToggleTerm direction='tab'\"<CR>",
			desc = "ToggleTerm: Open tab terminal.",
		},
		{
			"<Leader>ttv",
			"<cmd>exe v:count1 . \"ToggleTerm direction='vertical'\"<CR>",
			desc = "ToggleTerm: Open vertical terminal.",
		},
		{ "<Leader>ts", group = "Tree sitter" },
		{ "<Leader>tsc", group = "Context" },
		{ "<Leader>tsce", "<cmd>TSContextEnable<CR>", desc = "TreeSitter: Enable Context." },
		{ "<Leader>tscd", "<cmd>TSContextDisable<CR>", desc = "TreeSitter: Disable Context." },
		{
			"<Leader>tscj",
			function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end,
			desc = "TreeSitter: Jumping to context(upwards).",
		},
		{ "<Leader>tsu", "<cmd>TSUpdate<CR>", desc = "TreeSitter: Update Tree-Sitter" },
	})
end

-- Workspace関連のキー登録
local function registerWorkspaceKey()
	-- Normal mode
	require("which-key").add({
		{ "<Leader>w", group = "Workspace" },
		{
			"<Leader>wn",
			-- dependencies: `rcarriga/nvim-notify`
			"<cmd>Telescope notify<CR>",
			desc = "⭐︎Telescope: Show notify.",
		},
		{ "<Leader>wt", group = "Tab" },
		{ "<Leader>wtn", "<cmd>tabnext<CR>", desc = "⭐︎Tab: Move next tab." },
		{ "<Leader>wto", "<cmd>tabnew<CR>", desc = "⭐︎Tab: Open a new tab." },
		{ "<Leader>wtp", "<cmd>tabprevious<CR>", desc = "⭐︎Tab: Move previous tab." },
		{ "<Leader>wtq", "<cmd>tabclose<CR>", desc = "⭐︎Tab: Close tab." },
		{ "<Leader>wv", group = "VSCode" },
		{
			"<Leader>wvb",
			-- 現在のバッファをvscodeで開く
			function()
				if vim.fn.executable("code") == 0 then
					vim.notify("code command not found.")
					return
				end

				local project_path = vim.fn.getcwd()
				local file_path = vim.fn.expand("%:p")
				vim.fn.jobstart({ "code", project_path, file_path }, { detach = true })
			end,
			desc = "⭐︎VSCode: Open file.",
		},
		{
			"<Leader>wvw",
			-- 同じフォルダでvsocdeを開く
			function()
				if vim.fn.executable("code") == 0 then
					vim.notify("code command not found.")
					return
				end

				local path = vim.fn.expand("%:p:h")
				vim.fn.jobstart({ "code", path }, { detach = true })
			end,
			desc = "VSCode: Open folder.",
		},
		{ "<Leader>w/", group = "Search" },
		{
			"<Leader>w/*",
			require("telescope.builtin").grep_string,
			desc = "⭐︎Telescope: Search for the string under your cursor in Workspace.",
			mode = { "n", "v" },
		},
		{ "<Leader>w//", require("telescope.builtin").live_grep, desc = "⭐︎Telescope: Search in Workspace." },
	})
end

return {
	"folke/which-key.nvim",
	cond = condition,
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	config = function()
		local wk = require("which-key")
		wk.setup({
			preset = "helix",
		})

		-- キーの登録関数
		-- <Leader>キーの次の文字で分類
		registerLanguageKey() -- L"a"nguage
		registerBufferKey()
		registerCommandKey()
		registerCommandPalletKey()
		registerEditKey()
		registerFileKey()
		registerGitKey()
		registerLspAndLlmKey()
		registerMarkKey()
		registerOutlineKey()
		registerQuickfixAndLocation()
		registerWorkspaceKey()
		registerTerminalAndToolsKey()
	end,
}
