let s:script_dir = expand('<sfile>:p:h')

" Load base setting.
exec "so" (s:script_dir . "/base.vim")

" Load plugins.
" exec "so" (s:script_dir . "/plugin.vim")

" 各種設定の読み込み
call map(sort(split(globpath(s:script_dir, 'config/*.vim'))), {->[execute('exec "so" v:val')]})

