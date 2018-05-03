let mapleader =','

" Paste without autoindent
set pastetoggle=<leader>v

" Window movement keys
function! WinMove(key)
  let t:curwin = winnr()
  exec "wincmd ".a:key
  if (t:curwin == winnr()) "we havent moved
    if (match(a:key,'[jk]')) "were we going up/down
      wincmd v
    else
      wincmd s
    endif
    exec "wincmd ".a:key
  endif
endfunction

map <silent> <C-h> :call WinMove('h')<cr>
map <silent> <C-k> :call WinMove('k')<cr>
map <silent> <C-l> :call WinMove('l')<cr>
map <silent> <C-j> :call WinMove('j')<cr>

" Toggle NERDTree
nmap <silent> <leader>k :NERDTreeToggle<cr>
" expand to the path of the file in the current buffer
nmap <silent> <leader>y :NERDTreeFind<cr>

" YouCompleteMe goto
map <leader>g :YcmCompleter GoToDefinitionElseDeclaration<cr>

" Syntastic
map <leader>c :lclose<cr>
map <leader>o :lopen<cr>

" fugitive
map <leader>b :Gblame<cr>

" bind <leader>f to grep word under cursor
nnoremap <leader>f :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>
