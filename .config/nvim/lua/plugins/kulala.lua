-- mistweaverco/kulala.nvim
-- see: <https://github.com/mistweaverco/kulala.nvim>
--
-- http client

return {
	"mistweaverco/kulala.nvim",
	ft = { "http", "rest" },
	opts = {
		global_keymaps = true,
		-- デフォルトの <leader>R は RenderMarkdown と重なるため、Kulala 用の <leader>k に変える。
		global_keymaps_prefix = "<leader>k",
	},
}
