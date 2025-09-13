-- okuuva/auto-save.nvim
-- see: <https://github.com/okuuva/auto-save.nvim>
--
-- ファイルの自動保存を行う
-- BufLeave, FocusLostで保存した場合に、format on saveなどが自動実行されないため、defer_saveを残している。

return {
	"okuuva/auto-save.nvim",
	event = { "BufEnter" },
	opts = {
		trigger_events = {
			-- tmuxを利用する場合に"FocusLost"でファイルを保存するためには`set -g focus-events on`にしておく必要がある。
			-- see: <https://qiita.com/sijiaoh/items/874cd77e083b8ab05151>
			immediate_save = { "BufLeave", "FocusLost" },
			-- defer_save = { "InsertLeave", "TextChanged" },
			defer_save = {},
			cancel_deferred_save = { "InsertEnter" },
		},
		-- delay after which a pending save is executed
		debounce_delay = 1000,
	},
	keys = {
		{ "<Leader>u", "<cmd>ASToggle<CR>", desc = "AutoSave: Toggle auto save mode." },
	},
}
