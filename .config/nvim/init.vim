" 対象のOSを判定して設定ファイルのベースパスを決定
if has('win32')
  " windows
  let g:config_dir = expand('~/AppData/Local')
elseif has('mac')
  " mac
  let g:config_dir = expand('~/.config')
else
  " linux
  let g:config_dir = expand('~/.config')
endif

" 設定ファイルの場所をvim/neovim/vscode neovimで分けて設定
" rcフォルダの下に分割した設定ファイルがある前提で分割した設定ファイルを読み込む
" nvimより先にvscodeを判定しないと、vscode neovimを利用しているためnvim側で判定してしまう。
if exists('g:vscode')
  " vscode neovim extension設定
  let g:vim_home = expand(g:config_dir . '/nvim')
  let g:rc_dir = expand(g:vim_home . '/rc')
elseif has('nvim')
  " neovim設定
  let g:vim_home = expand(g:config_dir . '/nvim')
  let g:rc_dir = expand(g:vim_home . '/rc')
else
  " vim設定
  let g:vim_home = expand(g:config_dir . '/vim')
  let g:rc_dir = expand(g:vim_home . '/rc')
endif

" rcファイル読み込み関数
function! s:source_rc(rc_file_name)
  let rc_file = expand(g:rc_dir . '/' . a:rc_file_name)
  if filereadable(rc_file)
    execute 'source' rc_file
  endif
endfunction

" 基本設定
if exists('g:vscode')
  " vscode neovimの場合は行数表示などをvscodeに任せるため設定が異なる
  call s:source_rc('vscode.rc.vim')
else
  " vim or neovim
  call s:source_rc('base.rc.vim')
endif

" プラグイン設定
" nvimより先にvscodeを判定しないと、vscode neovimを利用しているためnvim側で判定してしまう。
if exists('g:vscode')
  " vscode neovimで利用するプラグイン
  call plug#begin()
  Plug 'asvetliakov/vim-easymotion'  " カーソル移動をラベルで行う(vscode neovim版)
  Plug 'tpope/vim-surround'  " visual modeで選択した文字列を囲む
  call plug#end()

  " pluginのための設定
  call s:source_rc('easymotion-vscode.rc.vim')
elseif has('nvim')
  " neovimで利用するプラグイン
else
  " vimで利用するプラグイン
endif

