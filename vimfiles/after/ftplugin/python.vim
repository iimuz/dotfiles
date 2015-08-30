" .vim/after/ftplugin/python.vim

setlocal smarttab
setlocal expandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal foldmethod=indent
setlocal commentstring=#%s

" jedi-vimの設定
setlocal omnifunc=jedi#completions
let g:jedi#completions_enabled = 0
let g:jedi#auto_vim_configuration = 0

" 構文チェックの設定
let g:syntastic_python_checkers = ["flake8"]
