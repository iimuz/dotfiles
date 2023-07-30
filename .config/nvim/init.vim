" vim/neovimのベースとなる設定ファイル。
" 本ファイルをvim/neovim用にリンクを生成することを想定している。
" 例えば、vimであれば下記のように実施する。
" `ln -s /path/to/.config/nvim/init.vim ~/.vimrc`
" neovimの場合はフォルダごとシンボリックリンクを設定する。
" `ln -s /path/to/.config/nvim ~/.config/nvim`

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
" rcフォルダの下に分割した設定ファイルがある前提で分割した設定ファイルを読み込む。
" nvimより先にvscodeを判定しないと、vscode neovimを利用しているためnvim側で判定してしまう。
if exists('g:vscode')
  " vscode neovim extension設定
  " g:vim_home に対してjunktionを設定することを想定している。
  " 例えば、g:vim_home = ~/AppData/Local/nvim の場合は下記のようなコマンドを実施する。
  " `New-Item -ItemType Junction -Path ~/AppData/Local/nvim -Target /path/to/.config/nvim`
  let g:vim_home = expand(g:config_dir . '/nvim')
  let g:rc_dir = expand(g:vim_home . '/rc')
elseif has('nvim')
  " neovim設定
  " g:vim_home に対してsymlinkを設定することを想定している。
  " 例えば、g:vim_home = ~/.config/nvim の場合は下記のようなコマンドを実施する。
  " `ln -s /path/to/.config/nvim ~/.config/nvim`
  let g:vim_home = expand(g:config_dir . '/nvim')
  let g:rc_dir = expand(g:vim_home . '/rc')
else
  " vim設定
  " g:vim_home に対してsymlinkを設定することを想定している。
  " 例えば、g:vim_home = ~/.config/vim の場合は下記のようなコマンドを実施する。
  " `ln -s /path/to/.config/nvim ~/.config/vim`
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
let mapleader = "\<Space>"  " leaderキーは共通で設定
if exists('g:vscode')
  " vscode neovimの場合は行数表示などをvscodeに任せるため設定が異なる。
  call s:source_rc('vscode.rc.vim')
else
  " vim or neovim
  call s:source_rc('base.rc.vim')
endif

" プラグイン設定
" - pluginの設定には [vim-plug](https://github.com/junegunn/vim-plug) を利用する。
"   - 各環境でのvim-plugのインストール方法は公式ドキュメントを参照のこと。
" - nvimより先にvscodeを判定しないと、vscode neovimを利用しているためnvim側で判定してしまう。
if exists('g:vscode')
  " vscode neovimで利用するプラグイン
  call plug#begin()
    " カーソル移動をラベルで行う(vscode neovim版)
    " - vscode neovim v0.4.0 にてeasy motionのサポートが廃止されたため利用不可
    "   - <https://github.com/vscode-neovim/vscode-neovim/releases/tag/v0.4.0>
    " Plug 'asvetliakov/vim-easymotion'

    " カーソル移動をラベルで行う(easymotionの代替)
    " - neovimでは十分な速度で動作するがvscode上だとラベル表示が非常に遅いので使えなかった。
    " Plug 'phaazon/hop.nvim'

    " カーソル移動をラベルで行う(easymotionの代替)
    " - ライン移動ができないのと1文字で移動する時にラベルをつけてくれないが、動作するので利用中。
    Plug 'ggandor/lightspeed.nvim'

    Plug 'tpope/vim-surround'  " visual modeで選択した文字列を囲む
  call plug#end()

  " pluginのための設定
  " call s:source_rc('easymotion-vscode.rc.vim')  " pluginを無効化しているので削除
  " call s:source_rc('hop-vscode.rc.vim')  " pluginを無効化しているので削除
  call s:source_rc('lightspeed-vscode.rc.vim')
elseif has('nvim')
  " neovimで利用するプラグイン
  " なるべく素で利用するように注意する。多くのプラグインを入れ込まないように注意。
else
  " vimで利用するプラグイン
  " なるべく素で利用するように注意する。多くのプラグインを入れ込まないように注意。
endif
