-- folke/which-key.nvim
-- see: <https://github.com/folke/which-key.nvim>
--
-- ショートカットキーのコマンドパレット
--
-- ショートカットキーに登録するときの簡易ルール
-- - descriptionには、"⭐︎"を付けることでTelescopeで検索した時に優先して表示される。

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

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
	require("which-key").register({
		b = {
			name = "Buffer",
			l = { require("telescope.builtin").buffers, "⭐︎Telescope: Open buffer list." },
			["/"] = {
				require("telescope.builtin").current_buffer_fuzzy_find,
				"⭐︎Telescope: Live fuzzy search inside of the currently open buffer.",
			},
			z = {
				name = "Fold",
				a = { "za", "Fold: Toggle under the cursor." },
				A = { "zA", "Fold: Toggle all under the cursor." },
				c = { "zc", "⭐︎Fold: Close under the cursor." },
				C = { "zC", "⭐︎Fold: Close all under the cursor." },
				m = { "zm", "Fold: Close in Window." },
				M = { "zM", "⭐︎Fold: Close all in Window." },
				o = { "zo", "⭐︎Fold: Open under the cursor." },
				O = { "zO", "⭐︎Fold: Open all under the cursor." },
				r = { "zr", "Fold: Open in Window." },
				R = { "zR", "⭐︎Fold: Open all in Window." },
			},
		},
	}, { prefix = "<Leader>" })
end

-- コマンド関連のキー登録
local function registerCommandKey()
	require("which-key").register({
		c = {
			name = "Commands",
			l = {
				require("telescope.builtin").commands,
				"⭐︎Telescope: Open command list.",
			},
			h = {
				require("telescope.builtin").command_history,
				"⭐︎Telescope: Open command history list.",
			},
		},
	}, { prefix = "<Leader>" })
end

-- VSCodeのコマンドパレットと合わせるためのショートカットキー登録
local function registerCommandPalletKey()
	require("which-key").register({
		-- ファイル一覧を表示
		p = {
			"<cmd>Telescope find_files find_command=rg,--files,--hidden,--glob,!*.git<CR>",
			"⭐︎Telescope: Find files.",
		},
		--キー登録したコマンドパレットを表示
		-- see: <https://blog.atusy.net/2022/11/03/telescope-as-command-pallete/>
		P = {
			function()
				require("telescope.builtin").keymaps()
				vim.cmd("normal! i⭐︎")
			end,
			"⭐︎Telescope: Open command palet(keymaps).",
		},
	}, { prefix = "<Leader>" })
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

	require("which-key").register({
		e = {
			name = "Edit",
			a = {
				-- Toggle auto save.
				-- dependencies: `okuuva/auto-save.nvim`
				"<cmd>ASToggle<CR>",
				"AutoSave: Toggle auto save mode.",
			},
			c = {
				name = "Conform",
				d = {
					name = "Disable",
					b = {
						function()
							vim.b.disable_autoformat = true
						end,
						"Conform: Disable for this buffer.",
					},
					g = {
						function()
							vim.g.disable_autoformat = true
						end,
						"Conform: Disable.",
					},
				},
				e = {
					name = "Enable",
					b = {
						function()
							vim.b.disable_autoformat = false
						end,
						"⭐︎Conform: Enable for this buffer.",
					},
					g = {
						function()
							vim.g.disable_autoformat = false
						end,
						"Conform: Enable",
					},
				},
				i = { "<cmd>ConformInfo<CR>", "⭐︎Conform: Show information." },
			},
			f = {
				name = "Format",
				f = { format, "⭐︎Conform: Format file or range." },
				s = {
					function()
						vim.ui.input({ prompt = "Formatter: " }, function(formatter)
							format({ formatters = { formatter } })
						end)
					end,
					"⭐︎Conform: Specific formatter.",
				},
			},
			l = {
				-- dependencies: `mfussenegger/nvim-lint`
				function()
					require("lint").try_lint()
				end,
				"⭐︎Lint: Trigger linting for current file",
			},
			s = {
				-- dependencies: `benfowler/telescope-luasnip.nvim`
				"<cmd>Telescope luasnip<CR>",
				"⭐︎Telescope Luasnip: Open snippet list.",
			},
		},
	}, { prefix = "<Leader>" })
end

-- File関連のキー登録
local function registerFileKey()
	-- 指定した値をクリップボードにコピーする
	local function copyToClipboard(value)
		vim.notify("Copied: " .. value)
		vim.fn.setreg("+", value)
	end

	require("which-key").register({
		f = {
			name = "File",
			-- Open file browser.
			-- dependencies: `nvim-telescope/telescope-file-browser.nvim`
			b = { "<cmd>Telescope file_browser<CR>", "⭐︎Telescope FileBrowser: Open." },
			c = {
				name = "Copy file path",
				a = {
					function()
						copyToClipboard(vim.fn.expand("%:p"))
					end,
					"Self: Copy absolute file path.",
				},
				h = {
					function()
						copyToClipboard(vim.fn.expand("%:~"))
					end,
					"Self: Copy relative filepath from home.",
				},
				n = {
					function()
						copyToClipboard(vim.fn.expand("%:t"))
					end,
					"⭐︎Self: Copy file name.",
				},
				r = {
					function()
						copyToClipboard(vim.fn.expand("%:."))
					end,
					"⭐︎Self: Copy relative file path.",
				},
				w = {
					function()
						copyToClipboard(vim.fn.expand("%:t:r"))
					end,
					"⭐︎Self: Copy file name without suffix.",
				},
			},
			t = {
				function()
					local filepath = vim.fn.tempname()
					vim.cmd("edit " .. filepath)
				end,
				"⭐︎Zettelkasten: Create and open temporary file.",
			},
			v = { vifmToggle, "⭐︎ToggleTerm: Open vifm." },
		},
	}, { prefix = "<Leader>" })
end

-- Git関連のキー登録
--
-- dependencies:
-- - `sindrets/diffview.nvim`
-- - `pwntester/octo.nvim`
local function registerGitKey()
	require("which-key").register({
		g = {
			name = "Git",
			d = { "<cmd>DiffviewFileHistory %<CR>", "Diffview: Open file history." },
			e = {
				name = "Edit issue/PR",
				c = {
					name = "Comment",
					a = { "<cmd>Octo comment add<CR>", "⭐︎Octo: Add a new comment." },
					d = { "<cmd>Octo comment delete<CR>", "⭐︎Octo: Delete a comment." },
				},
				t = {
					name = "Thread",
					r = { "<cmd>Octo thread resolve<CR>", "⭐︎Octo: Resolve a review thread." },
					o = { "<cmd>Octo thread unresolve<CR>", "Octo: Unresolve a review thread." },
				},
			},
			i = {
				name = "GitHub Issue",
				l = { "<cmd>Octo issue list<CR>", "⭐︎Octo: List issues." },
				o = { "<cmd>Octo issue rowser<CR>", "Octo: Open current issue in the browser." },
				r = { "<cmd>Octo issue reload<CR>", "Octo: Reload issue." },
				u = { "<cmd>Octo issue url<CR>", "Octo: Copies the URL of the current issue to the system clipboard." },
				["/"] = { "<cmd>Octo issue search<CR>", "Octo: Live issue search." },
			},
			h = {
				name = "Hunk",
				b = {
					name = "Blame",
					e = {
						function()
							require("gitsigns").blame_line({ full = true })
						end,
						"GitSigns: Blame line.",
					},
					t = {
						function()
							require("gitsigns").toggle_current_line_blame()
						end,
						"GitSigns: Toggle line blame.",
					},
				},
				d = {
					function()
						require("gitsigns").toggle_deleted()
					end,
					"GitSigns: Toggle deleted.",
				},
				D = {
					name = "Diff",
					d = {
						function()
							require("gitsigns").diffthis()
						end,
						"GitSigns: Diff this.",
					},
					D = {
						function()
							require("gitsigns").diffthis("~")
						end,
						"GitSigns: Diff this (against HEAD~).",
					},
				},
				n = {
					function()
						if vim.wo.diff then
							vim.cmd.normal({ "]c", bang = true })
						else
							require("gitsigns").nav_hunk("next")
						end
					end,
					"GitSigns: Next hunk.",
				},
				p = {
					function()
						if vim.wo.diff then
							vim.cmd.normal({ "[c", bang = true })
						else
							require("gitsigns").nav_hunk("prev")
						end
					end,
					"GitSigns: Next hunk.",
				},
				r = {
					function()
						require("gitsigns").reset_hunk()
					end,
					"GitSigns: Reset hunk.",
				},
				R = {
					function()
						require("gitsigns").reset_buffer()
					end,
					"GitSigns: Reset buffer.",
				},
				s = {
					function()
						require("gitsigns").stage_hunk()
					end,
					"GitSigns: Stage hunk.",
				},
				S = {
					function()
						require("gitsigns").stage_buffer()
					end,
					"GitSigns: Stage buffer.",
				},
				u = {
					function()
						require("gitsigns").undo_stage_hunk()
					end,
					"GitSigns: Undo stage hunk.",
				},
				v = {
					function()
						require("gitsigns").preview_hunk()
					end,
					"GitSigns: Preview hunk.",
				},
			},
			g = { "<cmd>Octo gist list<CR>", "Octo: List user gists." },
			l = { lazygitToggle, "⭐︎ToggleTerm: Open lazygit." },
			p = {
				name = "Pull request",
				c = { "<cmd>Octo pr checkout<CR>", "⭐︎Octo: Checkout PR." },
				-- Show PR review.
				-- PR Review用に分岐元との差分を表示
				-- see: <https://github.com/sindrets/diffview.nvim/blob/main/USAGE.md>
				d = {
					name = "Diff",
					b = {
						function()
							vim.ui.input({ prompt = "Enter base branch name: " }, function(branch_name)
								local base_hash = vim.fn.system("git merge-base " .. branch_name .. " HEAD")
								vim.cmd("DiffviewOpen " .. base_hash .. " ...HEAD --imply-local")
							end)
						end,
						"Diffview: PR for specific branch.",
					},
					l = {
						"<cmd>DiffviewFileHistory --range=origin/HEAD...HEAD --right-only --no-merges<CR>",
						"Diffview: Open large PR.",
					},
					o = {
						"<cmd>DiffviewOpen origin/HEAD...HEAD --imply-local<CR>",
						"⭐︎Diffview: Open PR.",
					},
					t = { "<cmd>Octo pr diff<CR>", "Octo: Show PR diff." },
				},
				h = { "<cmd>Octo pr checks<CR>", "Octo: Show the status of all checks run on the PR." },
				l = { "<cmd>Octo pr list<CR>", "⭐︎Octo: List PRs." },
				m = { "<cmd>Octo pr commits<CR>", "Octo: List all PR commits." },
				n = { "<cmd>Octo pr reload<CR>", "Octo: Reload PR." },
				o = { "<cmd>Octo pr browser<CR>", "Octo: Open current PR in the browser." },
				r = {
					name = "Review",
					b = { "<cmd>Octo review submit<CR>", "⭐︎Octo: Submit the review." },
					c = { "<cmd>Octo review comments<CR>", "⭐︎Octo: View pending review comments." },
					d = { "<cmd>Octo review discard<CR>", "Octo: Deletes a pending review for current PR if any." },
					q = { "<cmd>Octo review close<CR>", "⭐︎Octo: Close the review window and return to the PR." },
					r = { "<cmd>Octo review resume<CR>", "⭐︎Octo: Edit a pending review for current PR." },
					s = { "<cmd>Octo review start<CR>", "⭐︎Octo: Start a new review." },
				},
				u = { "<cmd>Octo pr url<CR>", "Octo: Copies the URL of the current PR to the system clipboard." },
				["/"] = { "<cmd>Octo pr search<CR>", "Octo: Live PR search." },
			},
			r = {
				name = "Repository",
				b = { "<cmd>Octo repo browser<CR>", "Octo: Open current repo in the browser." },
				u = {
					"<cmd>Octo repo url<CR>",
					"Octo: Copies the URL of the current repository to the system clipboard.",
				},
			},
		},
	}, { prefix = "<Leader>" })

	-- ビジュアルモード
	require("which-key").register({
		g = {
			name = "Git",
			h = {
				name = "Hunk",
				-- git sign for visual mode
				-- dependencies: `lewis6991/gitsigns.nvim`
				s = {
					function()
						require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end,
					"GitSigns: Stage hunk.",
				},
				r = {
					function()
						require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end,
					"GitSigns: Reset hunk.",
				},
			},
		},
	}, { mode = "v", prefix = "<Leader>" })
end

-- 言語関連のキー登録
--
-- 先頭は言語を分けるためのプレフィックスとして利用する
-- "l"は予約済みのため、二文字目の"a"を利用する。
local function registerLanguageKey()
	require("which-key").register({
		a = {
			name = "Language",
			m = {
				name = "Markdown",
				b = {
					function()
						require("markdown-hop-links").frontMatterPicker()
					end,
					"⭐︎MarkdownLinkHops: Show backlinks.",
				},
				l = {
					name = "Auto lastmod",
					b = {
						name = "Buffer",
						d = { require("auto-lastmod").disable_buffer, "⭐︎AutoLastMod: Disable auto-lastmod" },
						e = { require("auto-lastmod").enable_buffer, "AutoLastMod: Enable auto-lastmod" },
					},
					g = {
						name = "Global",
						d = { require("auto-lastmod").disable_global, "⭐︎AutoLastMod: Disable auto-lastmod" },
						e = { require("auto-lastmod").enable_global, "AutoLastMod: Enable auto-lastmod" },
					},
				},
				f = {
					name = "Front matter",
					c = {
						function()
							vim.ui.input({ prompt = "Category: " }, function(category)
								require("front-matter-searcher").frontMatterPicker({
									select_query = 'select(.categories[]? == "' .. category .. '")',
								})
							end)
						end,
						"⭐︎FrontMatterSearcher: Search by Category.",
					},
					g = {
						function()
							vim.ui.input({ prompt = "Tag: " }, function(tag)
								require("front-matter-searcher").frontMatterPicker({
									select_query = 'select(.tags[]? == "' .. tag .. '")',
								})
							end)
						end,
						"⭐︎FrontMatterSearcher: Search by tag.",
					},
					t = {
						function()
							require("front-matter-searcher").frontMatterPicker()
						end,
						"⭐︎FrontMatterSearcher: Search by title.",
					},
				},
				p = {
					-- dependencies: `iamcco/markdown-preview.nvim`
					name = "Preview",
					s = { "<cmd>MarkdownPreview<CR>", "⭐︎MarkdownPreview: Start." },
					q = { "<cmd>MarkdownPreviewStop<CR>", "MarkdownPreview: Stop." },
				},
				t = {
					name = "Timestamp",
					d = {
						function()
							local ti = require("timestamp-inserter")
							vim.api.nvim_put({ ti.timestamp2DateStr(ti.getNowEpoch()) }, "c", true, true)
						end,
						"⭐︎TimestampInserter: Insert current date.",
					},
					f = {
						function()
							local ti = require("timestamp-inserter")
							vim.api.nvim_put({ ti.timestamp2DateTimeStr(ti.getNowEpoch()) }, "c", true, true)
						end,
						"TimestampInserter: Insert current date and time.",
					},
					t = {
						function()
							local ti = require("timestamp-inserter")
							vim.api.nvim_put({ ti.timestamp2TimeStr(ti.getNowEpoch()) }, "c", true, true)
						end,
						"⭐︎TimestampInserter: Insert current time.",
					},
				},
			},
		},
	}, { prefix = "<Leader>" })
end

-- LSPとLLMに関連するキー登録
--
-- dependencies: `CopilotC-Nvim/CopilotChat.nvim`
local function registerLspAndLlmKey()
	-- Normal mode
	require("which-key").register({
		l = {
			name = "LSP and LLM",
			c = {
				name = "GitHub Copilot Chat",
				c = {
					function()
						require("CopilotChat").close()
					end,
					"CopilotChat: Close chat window.",
				},
				i = {
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
					"⭐︎CopilotChat: Inline chat",
				},
				o = { "<cmd>CopilotChatOpen<CR>", "⭐︎CopilotChat: Open chat window." },
				q = {
					function()
						vim.ui.input({ prompt = "Quick Chat: " }, function(text)
							if text ~= "" then
								require("CopilotChat").ask(text, { selection = require("CopilotChat.select").buffer })
							end
						end)
					end,
					"⭐︎CopilotChat: Quick chat",
				},
				r = {
					function()
						require("CopilotChat").reset()
					end,
					"CopilotChat: Reset chat window.",
				},
			},
			-- eはLSPのtelescope利用版で利用済み
			g = {
				name = "GitHub Copilot",
				e = { "<cmd>Copilot enable<CR>", "Copilot: Enable." },
				d = { "<cmd>Copilot disable<CR>", "Copilot: Disable." },
				i = { "<cmd>Copilot signin<CR>", "Copilot: Signin." },
				o = { "<cmd>Copilot signout<CR>", "Copilot: Signout." },
				p = { "<cmd>Copilot panel<CR>", "Copilot: Show panel." },
				r = { "<cmd>Copilot restart<CR>", "Copilot: Restart." },
				s = { "<cmd>Copilot status<CR>", "⭐︎Copilot: Show status." },
				u = { "<cmd>Copilot setup<CR>", "Copilot: Setup." },
			},
			-- `l`はLSPで利用済み
			t = {
				name = "Trouble",
				d = {
					function()
						require("trouble").toggle("document_diagnostics")
					end,
					"Trouble: Toggle document diagnostics.",
				},
				l = {
					function()
						require("trouble").toggle("loclist")
					end,
					"Trouble: Toggle location list.",
				},
				q = {
					function()
						require("trouble").toggle("quickfix")
					end,
					"Trouble: Toggle quickfix.",
				},
				r = {
					function()
						require("trouble").toggle("lsp_references")
					end,
					"Trouble: Toggle LSP references.",
				},
				w = {
					function()
						require("trouble").toggle("workspace_diagnostics")
					end,
					"Trouble: Toggle workspace diagnostics.",
				},
				x = {
					function()
						require("trouble").toggle()
					end,
					"Trouble: Toggle.",
				},
			},
		},
	}, { prefix = "<Leader>" })

	-- Visual mode
	-- Normal modeのキーの内、Visual modeで利用するもののみ登録する
	require("which-key").register({
		l = {
			name = "LSP and LLM",
			c = {
				name = "GitHub Copilot Chat",
				q = {
					function()
						local input = vim.fn.input("Quick Chat: ")
						if input ~= "" then
							require("CopilotChat").ask(input, { selection = require("CopilotChat.select").visual })
						end
						-- vim.ui.input({ prompt = "Quick Chat: " }, function(text)
						-- 	if text ~= "" then
						-- 		require("CopilotChat").ask(text, { selection = require("CopilotChat.select").visual })
						-- 	end
						-- end)
					end,
					"⭐︎CopilotChat: Quick chat",
				},
			},
		},
	}, { mode = "v", prefix = "<Leader>" })

	-- LspAttachしたときのみ設定を追加
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(ctx)
			-- see: <https://github.com/neovim/nvim-lspconfig?tab=readme-ov-file#suggested-configuration>
			require("which-key").register({
				l = {
					e = {
						name = "LSP with telescope",
						d = {
							require("telescope.builtin").lsp_definitions,
							"LSP Telescope: Go to definition.",
						},
						e = {
							name = "Diagnostics",
							b = {
								function()
									require("telescope.builtin").diagnostics({ bufnr = 0 })
								end,
								"LSP Telescope: Lists diagnostics for all open buffers.",
							},
							w = {
								require("telescope.builtin").diagnostics,
								"LSP Telescope: Lists diagnostics for all open buffers.",
							},
						},
						i = {
							require("telescope.builtin").lsp_implementations,
							"LSP Telescope: Go to implementation.",
						},
						n = {
							require("telescope.builtin").lsp_incoming_calls,
							"LSP Telescope: Lists LSP incoming calls.",
						},
						o = {
							require("telescope.builtin").lsp_outgoing_calls,
							"LSP Telescope: Lists LSP outgoing calls.",
						},
						r = { require("telescope.builtin").lsp_references, "LSP Telescope: Lists LSP References." },
						s = {
							name = "Document symbols",
							b = {
								require("telescope.builtin").lsp_document_symbols,
								"LSP Telescope: Lists LSP document symbols in the current buffer.",
							},
							w = {
								require("telescope.builtin").lsp_workspace_symbols,
								"LSP Telescope: Lists LSP document symbols in the current workspace.",
							},
							y = {
								require("telescope.builtin").lsp_dynamic_workspace_symbols,
								"LSP Telescope: Dynamically lists LSP for all workspace symbols.",
							},
						},
						t = {
							require("telescope.builtin").lsp_type_definitions,
							"LSP Telescope: Go to definition of the type.",
						},
					},
					l = {
						name = "LSP",
						a = { vim.lsp.buf.code_action, "⭐︎LSP: Code action." },
						d = { vim.lsp.buf.definition, "⭐︎LSP: Go to definition." },
						D = { vim.lsp.buf.declaration, "⭐︎LSP: Go to declaration." },
						e = {
							name = "Diagnostic",
							o = { vim.diagnostic.open_float, "⭐︎LSP: Show line diagnostics." },
							p = { vim.diagnostic.goto_prev, "⭐︎LSP: Go to previous diagnostics." },
							n = { vim.diagnostic.goto_next, "⭐︎LSP: Go to next diagnostics." },
							l = { vim.diagnostic.setloclist, "⭐︎LSP: Set loclist diagnostics." },
						},
						f = {
							function()
								vim.lsp.buf.format({ async = true })
							end,
							"⭐︎LSP: Formatting.",
						},
						i = { vim.lsp.buf.implementation, "⭐︎LSP: Go to implementation." },
						k = { vim.lsp.buf.signature_help, "⭐︎LSP: Show signature help." },
						K = { vim.lsp.buf.hover, "⭐︎LSP: Show hover." },
						n = { vim.lsp.buf.rename, "⭐︎LSP: Rename." },
						r = { vim.lsp.buf.references, "⭐︎LSP: Show references." },
						s = { "<cmd>LspInfo<CR>", "⭐︎LSP: Show lsp info." },
						t = { vim.lsp.buf.type_definition, "⭐︎LSP: Type definition." },
						w = {
							name = "workspace",
							a = { vim.lsp.buf.add_workspace_folder, "LSP: Add workspace folder." },
							r = { vim.lsp.buf.remove_workspace_folder, "LSP: Remove workspace folder." },
							l = { vim.lsp.buf.list_workspace_folders, "LSP: List workspace folders." },
						},
					},
				},
			}, {
				prefix = "<leader>",
				buffer = ctx.buff,
			})
		end,
	})
end

-- Marks関連のキー登録
local function registerMarkKey()
	require("which-key").register({
		m = {
			name = "Marks",
			l = { require("telescope.builtin").marks, "⭐︎Telescope: Lists vim marks." },
		},
	}, { prefix = "<Leader>" })
end

-- Outline関連のキー登録
--
-- dependencies:
--   - `hedyhli/outline.nvim`
--   - `stevearc/aerial.nvim`
local function registerOutlineKey()
	require("which-key").register({
		o = {
			name = "Outline",
			f = { "<cmd>OutlineFollow<CR>", "Outline: Go follow cursor position." },
			o = { "<cmd>OutlineOpen<CR>", "⭐︎Outline: Open." },
			q = { "<cmd>OutlineClose<CR>", "Outline: Close." },
			s = { "<cmd>OutlineStatus<CR>", "Outline: Show status." },
			r = { "<cmd>OutlinesRefresh<CR>", "Outline: Refresh of symbols." },
			t = { "<cmd>Telescope aerial<CR>", "Aerial: Open using telescope." },
		},
	}, { prefix = "<Leader>" })
end

-- QuickfixとLocation関連のキー登録
local function registerQuickfixAndLocation()
	require("which-key").register({
		q = {
			name = "Quickfix and Location list",
			l = {
				name = "Location list",
				n = { "<cmd>lnext<CR>", "⭐︎Location: Next." },
				o = { "<cmd>lopen<CR>", "⭐︎Location: Open." },
				p = { "<cmd>lprevious<CR>", "⭐︎Location: Previous." },
				q = { "<cmd>lclose<CR>", "⭐︎Location: Close." },
			},
			q = {
				name = "Quickfix",
				n = { "<cmd>cnext<CR>", "⭐︎Quickfix: Next." },
				o = { "<cmd>copen<CR>", "⭐︎Quickfix: Open." },
				p = { "<cmd>cprevious<CR>", "⭐︎Quickfix: Previous." },
				q = { "<cmd>cclose<CR>", "⭐︎Quickfix: Close." },
			},
		},
	}, { prefix = "<Leader>" })
end

-- Terminal関連のキー登録
--
-- dependencies: `akinsho/toggleterm.nvim`
-- `exe v:count1 . "ToggleTerm"`では、コマンドの前に数字を設定することで任意の端末を開くことができる。
-- 数字を設定しなければ、最初の端末を開くことができきる。
local function registerTerminalAndToolsKey()
	require("which-key").register({
		t = {
			name = "Terminal and Tools",
			l = { "<cmd>Lazy<CR>", "⭐︎Lazy: Show Lazy UI." },
			m = {
				name = "Mason",
				l = { "<cmd>MasonLog<CR>", "Mason: Show log." },
				o = { "<cmd>Mason<CR>", "⭐︎Mason: Show Mason UI." },
				u = {
					name = "Update",
					m = { "<cmd>MasonUpdate<CR>", "Mason: update." },
					t = { "<cmd>MasonToolsUpdate<CR>", "MasonTools: update." },
				},
			},
			t = {
				name = "Terminal",
				f = {
					"<cmd>exe v:count1 . \"ToggleTerm direction='float'\"<CR>",
					"⭐︎ToggleTerm: Open floating terminal.",
				},
				h = {
					"<cmd>exe v:count1 . \"ToggleTerm direction='horizontal'\"<CR>",
					"⭐︎ToggleTerm: Open horizontal terminal.",
				},
				n = { "<cmd>ToggleTermSetName<CR>", "ToggleTerm: Set a display name." },
				p = { "<cmd>TermSelect<CR>", "ToggleTerm: Select a terminal." },
				s = {
					name = "Send to terminal",
					l = { "<cmd>ToggleTermSendCurrentLine<CR>", "ToggleTerm: Send current line to terminal." },
					v = { "<cmd>ToggleTermSendVisualLines<CR>", "ToggleTerm: Send selected lines to terminal." },
					s = { "<cmd>ToggleTermSendVisualSelection<CR>", "ToggleTerm: Send selection to terminal." },
				},
				t = { "<cmd>exe v:count1 . \"ToggleTerm direction='tab'\"<CR>", "ToggleTerm: Open tab terminal." },
				v = {
					"<cmd>exe v:count1 . \"ToggleTerm direction='vertical'\"<CR>",
					"ToggleTerm: Open vertical terminal.",
				},
			},
			s = {
				name = "Tree sitter",
				c = {
					name = "Context",
					e = {
						"<cmd>TSContextEnable<CR>",
						"TreeSitter: Enable Context.",
					},
					d = {
						"<cmd>TSContextDisable<CR>",
						"TreeSitter: Disable Context.",
					},
					j = {
						function()
							require("treesitter-context").go_to_context(vim.v.count1)
						end,
						"TreeSitter: Jumping to context(upwards).",
					},
				},
				u = { "<cmd>TSUpdate<CR>", "TreeSitter: Update Tree-Sitter" },
			},
		},
	}, { prefix = "<Leader>" })
end

-- Workspace関連のキー登録
local function registerWorkspaceKey()
	-- Normal mode
	require("which-key").register({
		w = {
			name = "Workspace",
			n = {
				-- dependencies: `rcarriga/nvim-notify`
				"<cmd>Telescope notify<CR>",
				"⭐︎Telescope: Show notify.",
			},
			t = {
				name = "Tab",
				n = { "<cmd>tabnext<CR>", "⭐︎Tab: Move next tab." },
				o = { "<cmd>tabnew<CR>", "⭐︎Tab: Open a new tab." },
				p = { "<cmd>tabprevious<CR>", "⭐︎Tab: Move previous tab." },
				q = { "<cmd>tabclose<CR>", "⭐︎Tab: Close tab." },
			},
			v = {
				name = "VSCode",
				b = {
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
					"⭐︎VSCode: Open file.",
				},
				w = {
					-- 同じフォルダでvsocdeを開く
					function()
						if vim.fn.executable("code") == 0 then
							vim.notify("code command not found.")
							return
						end

						local path = vim.fn.expand("%:p:h")
						vim.fn.jobstart({ "code", path }, { detach = true })
					end,
					"VSCode: Open folder.",
				},
			},
			["/"] = {
				name = "Search",
				["*"] = {
					require("telescope.builtin").grep_string,
					"⭐︎Telescope: Search for the string under your cursor in Workspace.",
				},
				["/"] = { require("telescope.builtin").live_grep, "⭐︎Telescope: Search in Workspace." },
			},
		},
	}, { prefix = "<Leader>" })

	-- Visual mode
	require("which-key").register({
		w = {
			name = "Workspace",
			["/"] = {
				name = "Search",
				["/"] = {
					require("telescope.builtin").grep_string,
					"⭐︎Telescope: Search for the string your selection in Workspace.",
				},
			},
		},
	}, { mode = "v", prefix = "<Leader>" })
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
		wk.setup()

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
