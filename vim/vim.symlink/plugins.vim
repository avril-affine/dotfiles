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
Plug 'w0rp/ale'                         " async linter
Plug 'RRethy/vim-illuminate', {
    \ 'for': 'javascript' }             " highlight current word
Plug 'jiangmiao/auto-pairs'             " auto pair parens, brackets, etc.
Plug 'kshenoy/vim-signature'            " display markers on ruler
Plug 'pgdouyon/vim-evanesco'            " better search
Plug 'junegunn/vim-easy-align'          " easy align
Plug 'AndrewRadev/sideways.vim'         " swap arguments
" Autocomplete
if has('nvim')
  Plug 'Shougo/deoplete.nvim', {
    \ 'do': ':UpdateRemotePlugins'
    \ }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'autozimu/LanguageClient-neovim', {
  \ 'branch': 'next',
  \ 'do': 'bash install.sh',
  \ }
" python
Plug 'ambv/black'                       " black autoformatter
Plug 'fisadev/vim-isort'                " sort imports
if has('nvim')
  Plug 'numirias/semshi', {
    \ 'do': ':UpdateRemotePlugins',
    \ 'for': 'python'
    \ }                                 " semantic highlighting
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
let $FZF_DEFAULT_COMMAND='rg --hidden -l ""'

" ale
" let g:ale_linters = {'python': [ 'pyre' ]}
let g:ale_linters = {
  \ 'python': [ 'pylint', 'mypy' ],
  \ 'javascript': []
  \ }
let g:ale_python_pylint_options = "--rcfile ~/.pylintrc"

" vim-smooth-scroll
nnoremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 3)<CR>
nnoremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 3)<CR>

" vim-easy-align
nmap <leader>a <Plug>(EasyAlign)
vmap <leader>a <Plug>(EasyAlign)

" sideways
nnoremap <leader>l :SidewaysLeft<CR>
nnoremap <leader>r :SidewaysRight<CR>

" -----------------------------------------------------------------------------
" Autocomplete
" -----------------------------------------------------------------------------

" deoplete
let g:deoplete#enable_at_startup = 1
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"     " tab-complete
autocmd CompleteDone * pclose!                              " close preview when done

" LanguageClient
" Required for operations modifying multiple buffers like rename.
set hidden

let g:LanguageClient_serverCommands = {
  \ 'python': ['pyls'],
  \ 'javascript': ['flow', 'lsp', '--from', './node_modules/.bin'],
  \ 'javascript.jsx': ['flow', 'lsp', '--from', './node_modules/.bin'],
  \ }
let g:LanguageClient_diagnosticsEnable=0
autocmd FileType javascript let g:LangaugeClient_diagnosticsEnable=1
let g:LanguageClient_rootMarkers = {
  \ 'javascript': ['.flowconfig'],
  \ 'javascript.jsx': ['.flowconfig'],
  \ }

" Or map each action separately
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> <leader>d :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <leader>g :call LanguageClient#textDocument_implementation()<CR>
" nnoremap <silent> <leader>f :call LanguageClient#textDocument_references()<CR>
" nnoremap <silent> <leader>r :call LanguageClient#textDocument_rename()<CR>

" -----------------------------------------------------------------------------
" python
" -----------------------------------------------------------------------------

" black
autocmd BufWritePre *.py execute ':Black'
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
