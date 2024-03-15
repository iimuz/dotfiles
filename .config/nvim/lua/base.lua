--g 文字コードをUFT-8に設定
vim.scriptencoding = "utf-8"

vim.opt.encoding = "utf-8"
vim.opt.fileencodings = "utf-8,sjis"
vim.opt.fenc = "utf-8"
vim.opt.backup = false  -- バックアップファイルを作らない
vim.opt.swapfile = false  --g スワップファイルを作らない
vim.opt.autoread = true  --g 編集中のファイルが変更されたら自動で読み直す
vim.opt.hidden = true  --g バッファが編集中でもその他のファイルを開けるように

vim.opt.number = true  --g 行番号を表示
vim.opt.cursorline = false --g 現在の行を強調表示しない(全画面の再描画が発生し遅くなる環境があるため)
vim.opt.showmatch = false  --g 括弧入力時の対応する括弧を非表示
vim.opt.wildmode = {"list", "longest"}  --g コマンドラインの補完
vim.opt.showcmd = true  --g コマンドをステータス行に表示


vim.opt.statusline = string.format(
  '%s%s%s%s%s%s%s%s',
  '%F',  --g ファイル名表示
  '%m',  --g 変更チェック表示
  '%r',  --g 読み込み専用かどうか表示
  '%h',  --g ヘルプページなら[HELP]と表示
  '%w',  --g プレビューウインドウなら[Prevew]と表示
  '%=',  --g これ以降は右寄せ表示
  '[FMT=%{&ff}, TYPE=%Y, ENC=%{&fileencoding}]',  --g file encoding
  '[%l/%L,%c]'  --g 現在行数/全行数
)
--g ステータスラインを表示
--g 0:表示しない
--g 1: 2つ以上ウィンドウがある時だけ表示
--g 2: 常に表示
vim.opt.laststatus = 2

--g 不可視文字を可視化
vim.opt.listchars = {nbsp = '%', tab = '>-', extends = '<', trail = '-'}
vim.opt.list = true
vim.api.nvim_exec([[
augroup highlightIdegraphicSpace
  autocmd!
  autocmd Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  autocmd VimEnter,WinEnter * match IdeographicSpace /　/
augroup END
]], false)
vim.opt.expandtab = true  --g Tab文字を半角スペースにする
vim.opt.tabstop = 2  --g 行頭以外のTab文字の表示幅（スペースいくつ分）
vim.opt.shiftwidth = 2  --g 行頭でのTab文字の表示幅
vim.opt.smartindent = true  --g インデントはスマートインデント
vim.opt.backspace = {"indent", "eol", "start"}  --g バックスペースが効かなくなる問題への対応

vim.opt.ignorecase = true  --g 検索文字列が小文字の場合は大文字小文字を区別なく検索する
vim.opt.smartcase = true  --g 検索文字列に大文字が含まれている場合は区別して検索する
vim.opt.incsearch = true  --g 検索文字列入力時に順次対象文字列にヒットさせる
vim.opt.wrapscan = true  --g 検索時に最後まで行ったら最初に戻る
vim.opt.hlsearch = true  --g 検索語をハイライト表示

vim.opt.title = on  --g タイトルを表示
vim.cmd [[ syntax enable ]]  --g syntax
vim.cmd [[ colorscheme pablo ]]  --g カラースキーム
vim.opt.mouse = ""  --g マウス操作を無効
vim.opt.clipboard = "unnamedplus"  --g クリップボードを共有

vim.cmd [[ filetype plugin indent on ]]

