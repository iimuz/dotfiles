require("base") -- プラグインなどに関係ない基本設定
require("keymaps") -- プラグインに関係ないキーマップの基本設定
require("lazy-init") -- plugin managerとしてlazy.nvimを設定

-- 以下は自作コマンドなどの設定
require("auto-lastmod").setup() -- front matterのlatmod自動修正
require("clipboard").setup() -- Clipboardへのコピーコマンド
require("file").setup() -- File関連のコマンド
require("front-matter-searcher").setup() -- front matterを検索するコマンド
require("lsp").setup() -- LSP関連のコマンド
require("markdown-hop-links").setup()
require("quickfix").setup() -- quickfixとlocation listのコマンド
require("tab").setup() -- tab関連のコマンド
require("timestamp-inserter").setup() -- timestampを挿入するコマンド
require("vscode").setup() -- vscode関連のコマンド
