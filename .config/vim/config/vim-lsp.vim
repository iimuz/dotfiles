if empty(globpath(&rtp, 'autoload/lsp.vim'))
  finish
endif

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  inoremap <expr> <cr> pumvisible() ? "\<c-y>\<cr>" : "\<cr>"

  " Prefix key
  nnoremap [lsp] <Nop>
  nmap <Space>l [lsp]

  nmap <silent> [lsp]a <Plug>(lsp-code-action)
  nmap <silent> [lsp]c <Plug>(lsp-declaration)
  nmap <silent> [lsp]d <Plug>(lsp-definition)
  nmap <silent> [lsp]f <Plug>(lsp-document-format)
  nmap <silent> [lsp]i <Plug>(lsp-implementation)
  nmap <silent> [lsp]g <Plug>(lsp-document-diagnostics)
  nmap <silent> [lsp]r <Plug>(lsp-references)
  nmap <silent> [lsp]s <Plug>(lsp-document-symbol)
  nmap <silent> [lsp]] <Plug>(lsp-next-diagnostics)
  nmap <silent> [lsp][ <Plug>(lsp-previous-diagnostics)

  nmap <silent> [lsp]pc <Plug>(lsp-peek-declaration)
  nmap <silent> [lsp]pd <Plug>(lsp-peek-definition)
  nmap <silent> [lsp]pi <Plug>(lsp-peek-implementation)

  nmap <silent> [lsp]hh <Plug>(lsp-hover)
  nmap <silent> [lsp]hc <Plug>(lsp-preview-close)
  nmap <silent> [lsp]hf <Plug>(lsp-preview-focus)

  nmap <silent> [lsp]zzz <Plug>(lsp-next-error)
  nmap <silent> [lsp]zzz <Plug>(lsp-previous-error)
  nmap <silent> [lsp]zzz <Plug>(lsp-next-warning)
  nmap <silent> [lsp]zzz <Plug>(lsp-previous-warning)
  nmap <silent> [lsp]zzz <Plug>(lsp-rename)
  nmap <silent> [lsp]zzz <Plug>(lsp-type-definition)
  nmap <silent> [lsp]zzz <Plug>(lsp-type-hierarchy)
  nmap <silent> [lsp]zzz <Plug>(lsp-peek-type-hierarchy)
  nmap <silent> [lsp]zzz <Plug>(lsp-workdir-symbol)
  nmap <silent> [lsp]zzz <Plug>(lsp-document-range-format)
  nmap <silent> [lsp]zzz <Plug>(lsp-next-reference)
  nmap <silent> [lsp]zzz <Plug>(lsp-previous-reference)
  nmap <silent> [lsp]zzz <Plug>(lsp-signiture-help)
  nmap <silent> [lsp]zzz <Plug>(lsp-status)
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
command! LspDebug let lsp_log_verbose=1 | let lsp_log_file = expand('~/lsp.log')

let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:asyncomplete_auto_popup = 0
let g:asyncomplete_auto_completeopt = 0
let g:asyncomplete_popup_delay = 200
let g:lsp_text_edit_enabled = 1
