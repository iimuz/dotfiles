" for python filetype

"---------------------------------------------------------------------------
" Set local
setlocal smarttab
setlocal expandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal foldmethod=indent
setlocal commentstring=#%s

"---------------------------------------------------------------------------
" For Neobundle
NeoBundleSource jedivim                 " オムニ補完
NeoBundleSource flake8-vim              " スタイルチェック
NeoBundleSource vim-python-pep8-indent  " インデントを適切に導入する

"---------------------------------------------------------------------------
" For jedi-vim
setlocal omnifunc=jedi#completions
let g:jedi#completions_enabled = 0
let g:jedi#auto_vim_configuration = 0

"---------------------------------------------------------------------------
" 構文チェックの設定
let g:syntastic_python_checkers = ["flake8"]
