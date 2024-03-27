require("base") -- プラグインなどに関係ない基本設定
require("keymaps") -- プラグインに関係ないキーマップの基本設定
require("lsp") -- Builtin LSP設定
require("lazy-init") -- plugin managerとしてlazy.nvimを設定

require("auto-lastmod") -- front matterのlatmod自動修正
require("zettelkasten") -- zettelkasten関連の設定
require("project-settings") -- project rootのneovim設定を読み込む
