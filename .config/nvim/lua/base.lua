vim.opt.fileencodings = "utf-8,sjis"
vim.opt.fenc = "utf-8"
vim.opt.backup = false -- バックアップファイルを作らない
vim.opt.swapfile = false -- スワップファイルを作らない

vim.opt.number = true -- 行番号を表示
vim.opt.cursorline = true -- 現在の行を強調表示
vim.opt.showmatch = false -- 括弧入力時の対応する括弧を非表示
vim.opt.wildmode = { "list", "longest" } -- コマンドラインの補完

-- 不可視文字を可視化
vim.opt.listchars = { nbsp = "%", tab = ">-", extends = "<", trail = "-" }
vim.opt.list = true
vim.cmd([[
augroup highlightIdegraphicSpace
  autocmd!
  autocmd Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  autocmd VimEnter,WinEnter * match IdeographicSpace /　/
augroup END
]])
vim.opt.expandtab = true -- Tab文字を半角スペースにする
vim.opt.tabstop = 2 -- 行頭以外のTab文字の表示幅（スペースいくつ分）
vim.opt.shiftwidth = 2 -- 行頭でのTab文字の表示幅
vim.opt.smartindent = true -- インデントはスマートインデント

vim.opt.ignorecase = true -- 検索文字列が小文字の場合は大文字小文字を区別なく検索する
vim.opt.smartcase = true -- 検索文字列に大文字が含まれている場合は区別して検索する

vim.cmd([[ colorscheme pablo ]]) -- デフォルトで利用可能なカラースキーム
vim.opt.mouse = "" -- マウス操作を無効
vim.opt.clipboard = "unnamedplus" -- クリップボードを共有
if vim.fn.has("linux") == 1 then
	-- herdrや素のSSH端末はOSC 52の読み取り問い合わせに応答しないため、
	-- paste側は端末に問い合わせず自分のレジスタをそのまま返す
	local osc52 = require("vim.ui.clipboard.osc52")
	local function paste()
		return { vim.fn.getreg('"', 1, true), vim.fn.getregtype('"') }
	end
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = osc52.copy("+"),
			["*"] = osc52.copy("*"),
		},
		paste = {
			["+"] = paste,
			["*"] = paste,
		},
	}
end
