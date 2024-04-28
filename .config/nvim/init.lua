require("base") -- プラグインなどに関係ない基本設定
require("keymaps") -- プラグインに関係ないキーマップの基本設定
require("lsp") -- Builtin LSP設定
require("lazy-init") -- plugin managerとしてlazy.nvimを設定

-- 以下は自作コマンドなどの設定
require("auto-lastmod").setup() -- front matterのlatmod自動修正
require("front-matter-searcher").setup() -- front matterを検索するコマンド
require("markdown-hop-links").setup()
require("project-settings") -- project rootのneovim設定を読み込む
require("timestamp-inserter").setup() -- timestampを挿入するコマンド
