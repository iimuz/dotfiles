" lightspeedの設定
"
" line移動のコマンドが存在しないので、行末に移動するのであれば `Enter` で指定できる。

" lightspeedのデフォルトのキーバインドを全て無効化
let g:lightspeed_no_default_keymaps = 1

" Move to word
map  <Leader>s <Plug>Lightspeed_s
map  <Leader>S <Plug>Lightspeed_S

