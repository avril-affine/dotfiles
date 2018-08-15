set nocompatible

" Automatically install vim-plug if not installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" General
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Konfekt/FastFold'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } | Plug 'junegunn/fzf.vim'
Plug 'Yggdroot/indentLine', { 'branch': 'master' }
" Plug 'w0rp/ale'
Plug 'RRethy/vim-illuminate'

" Autocomplete
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" Python
Plug 'fisadev/vim-isort', { 'for': 'python' }

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
let NERDTreeShowHidden=1
let NERDTreeDirArrowExpandable = '▷'
let NERDTreeDirArrowCollapsible = '▼'
nnoremap <silent> <leader>k :NERDTreeToggle<cr>
nnoremap <silent> <leader>y :NERDTreeFind<cr>

" vim-airline
let g:airline_section_x=0   " clear section
let g:airline_section_y=0   " clear section
let g:airline_section_z = airline#section#create(['%l:%c ', "\u2630 ", ' %3p%%'])

" FZF
nnoremap <C-p> :Files<cr>

" indentLine
autocmd BufEnter *.json let g:indentLine_enabled = 0
autocmd BufLeave *.json let g:indentLine_enabled = 1

" " ale
" let g:ale_linters = {'python': ['pylint']}
" let g:ale_python_pylint_options = "--rcfile ~/.pylintrc"

" -----------------------------------------------------------------------------
" Autocomplete
" -----------------------------------------------------------------------------
"
" Required for operations modifying multiple buffers like rename.
set hidden

let g:LanguageClient_serverCommands = {
    \ 'python': ['pyls'],
    \ }

nnoremap <silent> <leader>f :call LanguageClient_contextMenu()<CR>
" Or map each action separately
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

" -----------------------------------------------------------------------------
" Python
" -----------------------------------------------------------------------------

" isort
let g:vim_isort_map = "<C-i>"
