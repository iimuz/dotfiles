"文字コードをUFT-8に設定
scriptencoding utf-8
set encoding=utf-8
set fileencodings=utf-8,sjis
set fenc=utf-8
" バックアップファイルを作らない
set nobackup
" スワップファイルを作らない
set noswapfile
" 編集中のファイルが変更されたら自動で読み直す
set autoread
" バッファが編集中でもその他のファイルを開けるように
set hidden

" 行番号を表示
set number
" 現在の行を強調表示しない(全画面の再描画が発生し遅くなる環境があるため)
set nocursorline
" 括弧入力時の対応する括弧を表示
" set showmatch
" コマンドラインの補完
set wildmode=list:longest
" コマンドをステータス行に表示
set showcmd

" ファイル名表示
set statusline=%F
" 変更チェック表示
set statusline+=%m
" 読み込み専用かどうか表示
set statusline+=%r
" ヘルプページなら[HELP]と表示
set statusline+=%h
" プレビューウインドウなら[Prevew]と表示
set statusline+=%w
" これ以降は右寄せ表示
set statusline+=%=
" file encoding
set statusline+=[FMT=%{&ff},\ TYPE=%Y,\ ENC=%{&fileencoding}]
" 現在行数/全行数
set statusline+=[%l/%L,%c]
" ステータスラインを表示
" 0:表示しない
" 1: 2つ以上ウィンドウがある時だけ表示
" 2: 常に表示
set laststatus=2

" 不可視文字を可視化
set listchars=nbsp:%,tab:>-,extends:<,trail:-
set list
augroup highlightIdegraphicSpace
  autocmd!
  autocmd Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  autocmd VimEnter,WinEnter * match IdeographicSpace /　/
augroup END
" Tab文字を半角スペースにする
set expandtab
" 行頭以外のTab文字の表示幅（スペースいくつ分）
set tabstop=2
" 行頭でのTab文字の表示幅
set shiftwidth=2
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

" タイトルを表示
set title
" syntax
syntax enable
" カラースキームです
colorscheme desert
" マウス操作を無効
set mouse=

filetype plugin indent on

