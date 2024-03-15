" vimのベースとなる設定ファイル。
" 本ファイルをvim用にリンクを生成することを想定している。
" 例えば、下記のように実施する。
" `ln -s /path/to/.config/nvim/init.vim ~/.vimrc`

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

" rcフォルダの下に分割した設定ファイルがある前提で分割した設定ファイルを読み込む。
" g:vim_home に対してsymlinkを設定することを想定している。
" 例えば、g:vim_home = ~/.config/vim の場合は下記のようなコマンドを実施する。
" `ln -s /path/to/.config/nvim ~/.config/vim`
let g:vim_home = expand(g:config_dir . '/vim')
let g:rc_dir = expand(g:vim_home . '/rc')

" rcファイル読み込み関数
function! s:source_rc(rc_file_name)
  let rc_file = expand(g:rc_dir . '/' . a:rc_file_name)
  if filereadable(rc_file)
    execute 'source' rc_file
  endif
endfunction

" 基本設定
let mapleader = "\<Space>"  " leaderキーは共通で設定
call s:source_rc('base.rc.vim')

" vimではプラグインを利用しない

