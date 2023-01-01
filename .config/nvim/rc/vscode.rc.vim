"文字コードをUFT-8に設定
scriptencoding utf-8
set encoding=utf-8
set fileencodings=utf-8,sjis
set fenc=utf-8
" バックアップファイルを作らない
set nobackup
" スワップファイルを作らない
set noswapfile
" バッファが編集中でもその他のファイルを開けるように
set hidden

" 行番号は非表示(VSCode側で表示)
set nonumber
" 現在の行を強調表示しない(全画面の再描画が発生し遅くなる環境があるため)
set nocursorline
" 括弧入力時の対応する括弧を表示
" set showmatch
" コマンドラインの補完
set wildmode=list:longest
" コマンドをステータス行に表示
set showcmd

" ステータスラインを表示しない
" 0:表示しない
" 1: 2つ以上ウィンドウがある時だけ表示
" 2: 常に表示
set laststatus=0

" インデントはスマートインデント
set smartindent
" バックスペースが効かなくなる問題への対応
set backspace=indent,eol,start

" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch
" 検索時に最後まで行ったら最初に戻る
set wrapscan
" 検索語をハイライト表示
set hlsearch

" LeaderキーをSpaceに設定
let mapleader = "\<Space>"
" クリップボードを共有
set clipboard+=unnamedplus

