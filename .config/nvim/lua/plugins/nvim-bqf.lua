-- kevinhwang91/nvim-bqf
-- see: <https://github.com/kevinhwang91/nvim-bqf>
--
-- Better quickfix window

return {
	"kevinhwang91/nvim-bqf",
	ft = "qf", -- Quickfixをを開いたときに有効化
	dependencies = {
		-- quickfix中でzfでfzfによる絞り込みに利用。別途fzfはインストールする必要がある。
		"junegunn/fzf",
	},
}
