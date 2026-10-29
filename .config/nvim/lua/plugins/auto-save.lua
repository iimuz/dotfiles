-- okuuva/auto-save.nvim
-- see: <https://github.com/okuuva/auto-save.nvim>
--
-- ファイルの自動保存を行う

-- Cmd+Q で終了すると BufLeave と FocusLost を受けずに終わることがあるので、
-- 下書きのファイルだけ入力の後に遅延保存する。ほかのファイルの保存の挙動は変えない
local drafts_pattern = (os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")) .. "/drafts/*.md"

return {
	"okuuva/auto-save.nvim",
	event = { "BufEnter" },
	opts = {
		trigger_events = {
			immediate_save = { "BufLeave", "FocusLost" },
			defer_save = {
				{ "InsertLeave", pattern = drafts_pattern },
				{ "TextChanged", pattern = drafts_pattern },
				{ "TextChangedI", pattern = drafts_pattern },
			},
			cancel_deferred_save = { "InsertEnter" },
		},
		-- delay after which a pending save is executed
		debounce_delay = 1000,
	},
	keys = {
		{ "<Leader>U", "<cmd>ASToggle<CR>", desc = "AutoSave: Toggle auto save mode." },
	},
}
