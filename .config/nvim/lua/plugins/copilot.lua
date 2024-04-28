-- github/copilot.vim
-- see: <https://github.com/github/copilot.vim>
--
-- GitHub Copilot Plugin.

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
	"github/copilot.vim",
	cond = condition,
	cmd = "Copilot",
	config = function() end,
}
