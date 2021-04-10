set nocompatible

" Automatically install vim-plug if not installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" General
Plug 'tpope/vim-fugitive'               " git
Plug 'rbong/vim-flog'                   " git branch viewer
Plug 'scrooloose/nerdtree'              " file explorer
Plug 'Xuyuanp/nerdtree-git-plugin'      " show git status in nerdtree
Plug 'vim-airline/vim-airline'          " status line formatting
Plug 'vim-airline/vim-airline-themes'   " status line themes
Plug 'Konfekt/FastFold'                 " faster code folding
Plug 'terryma/vim-smooth-scroll'        " smooth scrolling
Plug 'junegunn/fzf', {
  \ 'dir': '~/.fzf',
  \ 'do': './install --all'
  \ }
  \ | Plug 'junegunn/fzf.vim'           " fuzzy finder
Plug 'nathanaelkane/vim-indent-guides'  " indent markers
Plug 'elzr/vim-json'
Plug 'RRethy/vim-illuminate', {
    \ 'for': 'javascript'
    \ }                                 " highlight current word
Plug 'jiangmiao/auto-pairs'             " auto pair parens, brackets, etc.
Plug 'kshenoy/vim-signature'            " display markers on ruler
Plug 'pgdouyon/vim-evanesco'            " better search
Plug 'junegunn/vim-easy-align'          " easy align
Plug 'AndrewRadev/sideways.vim'         " swap arguments
Plug 'ruanyl/vim-gh-line'               " open browser to github line
Plug 'majutsushi/tagbar'                " displays tags in separate window
Plug 'kdheepak/lazygit.nvim', {
    \ 'branch': 'nvim-v0.4.3'
    \ }                                       " lazygit in vim
" " Autocomplete
Plug 'neoclide/coc.nvim', {
    \ 'branch': 'release'
    \ }
" python
Plug 'ambv/black', {
  \ 'tag': '19.10b0'
  \ }                                   " black autoformatter
Plug 'kkihara/vim-isort'                " sort imports
if has('nvim')
  " Plug 'numirias/semshi', {
  "   \ 'commit': '816b8d22adf59260f4355aab31c1cdc99db8f438',
  "   \ 'do': ':UpdateRemotePlugins',
  "   \ 'for': 'python'
  "   \ }                                 " semantic highlighting
  Plug 'numirias/semshi'
endif
" Miscellaneous
Plug 'ivan-krukov/vim-snakemake'        " snakemake syntax highlighting

call plug#end()

" Automatically install missing plugins on startup
if !empty(filter(copy(g:plugs), '!isdirectory(v:val.dir)'))
  autocmd VimEnter * PlugInstall --sync | q
endif

" -----------------------------------------------------------------------------
" General
" -----------------------------------------------------------------------------

" fugitive
nnoremap <leader>b :Gblame<cr>

" NERDTree
let NERDTreeShowHidden=0
let NERDTreeDirArrowExpandable = '▷'
let NERDTreeDirArrowCollapsible = '▼'
nnoremap <silent> <leader>k :NERDTreeToggle<cr>

" vim-airline
let g:airline_section_x=0   " clear section
let g:airline_section_y=0   " clear section
let g:airline_section_z = airline#section#create(['%l:%c ', "\u2630 ", ' %3p%%'])

" vim-indent-guide
let g:indent_guides_enable_on_vim_startup=1
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=239

" FZF
nnoremap <C-p> :Files<cr>
let $FZF_DEFAULT_COMMAND='rg --hidden -l --glob=\!.git --glob \!__pycache__ ""'

" vim-smooth-scroll
nnoremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 3)<CR>
nnoremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 3)<CR>

" vim-easy-align
nmap <leader>a <Plug>(EasyAlign)
vmap <leader>a <Plug>(EasyAlign)

" sideways
nnoremap <leader>l :SidewaysLeft<CR>
nnoremap <leader>r :SidewaysRight<CR>

" vim-gh-line
let g:gh_line_map = '<leader>g'

" tagbar
nmap <leader>t :TagbarToggle<CR>

" LazyGit
command Lg LazyGit
command LG LazyGit

" -----------------------------------------------------------------------------
" Autocomplete
" -----------------------------------------------------------------------------

let b:coc_enabled = 0
" nmap <silent> <leader> f <Plug>(coc-references)
nmap <silent> <leader>d <Plug>(coc-definition)
nmap <F2> <Plug>(coc-rename)

"" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

" -----------------------------------------------------------------------------
" python
" -----------------------------------------------------------------------------

" black/isort
autocmd BufWritePre *.py execute ':Black' | execute ':Isort' | execute ':Semshi highlight'
let g:black_linelength=100

" semshi
if has('nvim')
  nmap <silent> <Tab> :Semshi goto name next<CR>
  nmap <silent> <S-Tab> :Semshi goto name prev<CR>
endif

" light blue selected background
function MyCustomHighlights()
    hi semshiSelected ctermfg=0 guifg=#ffffff ctermbg=45 guibg=#d7005f
endfunction
autocmd FileType python call MyCustomHighlights()

" reset <C-I> to default behavior
unmap <C-I>

" nmap <silent> <Tab> :Semshi goto name next<CR>
nmap <silent> <S-Tab> :Semshi goto name prev<CR>
