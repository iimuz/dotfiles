" Hop settings
" Initialize
lua << EOF
  require('hop').setup()
EOF

" Move to word
nnoremap <silent> <Leader>f :HopChar1<CR>
nnoremap <silent> <Leader>w :HopWord<CR>
" Move to line
nnoremap <silent> <Leader>l :HopLine<CR>

