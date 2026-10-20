-- okuuva/auto-save.nvim
-- see: <https://github.com/okuuva/auto-save.nvim>
--
-- ファイルの自動保存を行う

return {
	"okuuva/auto-save.nvim",
	event = { "BufEnter" },
	opts = {
		trigger_events = {
			immediate_save = { "BufLeave", "FocusLost" },
			-- defer_save = { "InsertLeave", "TextChanged" },
			defer_save = {},
			cancel_deferred_save = { "InsertEnter" },
		},
		-- delay after which a pending save is executed
		debounce_delay = 1000,
	},
	keys = {
		{ "<Leader>U", "<cmd>ASToggle<CR>", desc = "AutoSave: Toggle auto save mode." },
	},
}
