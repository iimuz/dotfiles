require("base") -- プラグインなどに関係ない基本設定
require("keymaps") -- プラグインに関係ないキーマップの基本設定
require("lsp") -- Builtin LSP設定
require("lazy-init") -- plugin managerとしてlazy.nvimを設定

require("auto-lastmod") -- front matterのlatmod自動修正
require("front-matter-searcher") -- front matterを検索するコマンド
require("project-settings") -- project rootのneovim設定を読み込む
require("vscode") -- vscodeの設定
require("zettelkasten") -- zettelkasten関連の設定
