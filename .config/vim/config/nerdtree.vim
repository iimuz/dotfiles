if empty(globpath(&rtp, 'autoload/nerdtree.vim'))
  finish
endif

map <C-n> :NERDTreeToggle<CR>

