require("base")     -- プラグインなどに関係ない基本設定

-- plugin managerとしてlazy.nvimを設定
-- vscodeから利用する場合は拡張機能が異なるため利用するプラグインは別ファイルで設定
require("plugins/lazy")
if vim.g.vscode then
  require("plugins/lazy-vscode")
else
  require("plugins/lazy-neovim")
end


