-- 文字コードをUFT-8に設定
vim.scriptencoding = "utf-8"

vim.opt.encoding = "utf-8"
vim.opt.fileencodings = "utf-8,sjis"
vim.opt.fenc = "utf-8"
vim.opt.backup = false -- バックアップファイルを作らない
vim.opt.swapfile = false -- スワップファイルを作らない
vim.opt.autoread = true -- 編集中のファイルが変更されたら自動で読み直す
vim.opt.hidden = true -- バッファが編集中でもその他のファイルを開けるように

vim.opt.number = true -- 行番号を表示
vim.opt.cursorline = true -- 現在の行を強調表示しない(全画面の再描画が発生し遅くなる環境があるため)
vim.opt.showmatch = false -- 括弧入力時の対応する括弧を非表示
vim.opt.wildmode = { "list", "longest" } -- コマンドラインの補完
vim.opt.showcmd = true -- コマンドをステータス行に表示

vim.opt.statusline = string.format(
	"%s%s%s%s%s%s%s%s",
	"%F", -- ファイル名表示
	"%m", -- 変更チェック表示
	"%r", -- 読み込み専用かどうか表示
	"%h", -- ヘルプページなら[HELP]と表示
	"%w", -- プレビューウインドウなら[Prevew]と表示
	"%=", -- これ以降は右寄せ表示
	"[FMT=%{&ff}, TYPE=%Y, ENC=%{&fileencoding}]", -- file encoding
	"[%l/%L,%c]" -- 現在行数/全行数
)
-- ステータスラインを表示
-- 0:表示しない
-- 1: 2つ以上ウィンドウがある時だけ表示
-- 2: 常に表示
-- 3: neovimインスタンスで一つ(splitしても別れない)
vim.opt.laststatus = 3

-- 不可視文字を可視化
vim.opt.listchars = { nbsp = "%", tab = ">-", extends = "<", trail = "-" }
vim.opt.list = true
vim.api.nvim_exec(
	[[
augroup highlightIdegraphicSpace
  autocmd!
  autocmd Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  autocmd VimEnter,WinEnter * match IdeographicSpace /　/
augroup END
]],
	false
)
vim.opt.expandtab = true -- Tab文字を半角スペースにする
vim.opt.tabstop = 2 -- 行頭以外のTab文字の表示幅（スペースいくつ分）
vim.opt.shiftwidth = 2 -- 行頭でのTab文字の表示幅
vim.opt.smartindent = true -- インデントはスマートインデント
vim.opt.backspace = { "indent", "eol", "start" } -- バックスペースが効かなくなる問題への対応

vim.opt.ignorecase = true -- 検索文字列が小文字の場合は大文字小文字を区別なく検索する
vim.opt.smartcase = true -- 検索文字列に大文字が含まれている場合は区別して検索する
vim.opt.incsearch = true -- 検索文字列入力時に順次対象文字列にヒットさせる
vim.opt.wrapscan = true -- 検索時に最後まで行ったら最初に戻る
vim.opt.hlsearch = true -- 検索語をハイライト表示

vim.opt.title = on -- タイトルを表示
vim.cmd([[ syntax enable ]]) -- syntax
vim.cmd([[ colorscheme pablo ]]) -- デフォルトで利用可能なカラースキーム
vim.opt.mouse = "" -- マウス操作を無効
vim.opt.clipboard = "unnamedplus" -- クリップボードを共有

vim.cmd([[ filetype plugin indent on ]])
