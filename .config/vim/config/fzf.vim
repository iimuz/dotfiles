if empty(globpath(&rtp, 'autoload/fzf/vim.vim'))
  finish
endif

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, {'options': ['--layout=reverse', '--info=inline', '--preview', 'bat {}']}, <bang>0)
command! -bang -nargs=? -complete=dir HFiles
  \ call fzf#vim#files(<q-args>, {'source': 'rg --hidden --files', 'options': ['--layout=reverse', '--info=inline', '--preview', 'bat {}']}, <bang>0)
command! -bang -nargs=? -complete=dir GFiles
  \ call fzf#vim#gitfiles(<q-args>, {'options': ['--layout=reverse', '--info=inline', '--preview', 'bat {}']}, <bang>0)
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   "rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* RgHidden
  \ call fzf#vim#grep(
  \   "rg --column --line-number --no-heading --color=always --smart-case --hidden ".shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

" Prefix key
nnoremap [fzf] <Nop>
nmap <Space>f [fzf]
nmap <silent> [fzf]b :<C-u>Buffers<CR>
nmap <silent> [fzf]c :<C-u>Commands<CR>
nmap <silent> [fzf]f :<C-u>Files<CR>
nmap <silent> [fzf]F :<C-u>HFiles<CR>
nmap <silent> [fzf]g :<C-u>Rg<CR>
nmap <silent> [fzf]G :<C-u>RgHidden<CR>
nmap <expr> [fzf]G/ ':<C-u>RgHidden '.expand('<cword>').'<CR>'
nmap <silent> [fzf]h :<C-u>History<CR>
nmap <silent> [fzf]H: :<C-u>History:<CR>
nmap <silent> [fzf]H/ :<C-u>/History<CR>
nmap <silent> [fzf]m :<C-u>Marks<CR>
nmap <silent> [fzf]p :<C-u>GFiles<CR>
nmap <silent> [fzf]t :<C-u>Tags<CR>
nmap <silent> [fzf]T :<C-u>BTags<CR>
nmap <silent> [fzf]l :<C-u>Lines<CR>
nmap <silent> [fzf]L :<C-u>BLines<CR>
nmap <expr> [fzf]/ ':<C-u>Rg '.expand('<cword>').'<CR>'

