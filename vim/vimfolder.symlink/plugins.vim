" Brief help
" " :PluginList       - lists configured plugins
" " :PluginInstall    - installs plugins; append `!` to update or just
" :PluginUpdate
" " :PluginSearch foo - searches for foo; append `!` to refresh local cache
" " :PluginClean      - confirms removal of unused plugins; append `!` to
" auto-approve removal
" "
" " see :h vundle for more details or wiki for FAQ
" " Put your non-Plugin stuff after this line

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Plugins
Plugin 'tpope/vim-fugitive'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'tmhedberg/SimpylFold'
Plugin 'Valloric/YouCompleteMe'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'RRethy/vim-illuminate'
Plugin 'w0rp/ale'
Plugin 'fisadev/vim-isort'
Plugin 'nathanaelkane/vim-indent-guides'

call vundle#end()            " required
filetype plugin indent on    " required

" NerdTree configs
let NERDTreeShowHidden=1
let NERDTreeDirArrowExpandable = '▷'
let NERDTreeDirArrowCollapsible = '▼'

" Syntastic configs
let python_highlight_all=1
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

syntax on

" SimplyFold docstrings
let g:SimplyFold_docstring_preview=1
let g:SimpylFold_fold_docstring=0
autocmd BufWinEnter * let &foldlevel = max(map(range(1, line('$')), 'foldlevel(v:val)'))

" YouCompleteMe configs
let g:ycm_autoclose_preview_window_after_completion=1
let g:ycm_python_binary_path=substitute(system("which python3"), "\n", '', 'g')

" vim-indent-guides
let g:indent_guides_enable_on_vim_startup=1
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * hi IndentGuidesEven ctermbg=239


" vim-airline
let g:airline_section_x=0
let g:airline_section_y=0
let g:airline_section_z = airline#section#create(['%l:%c ', "\u2630 ", ' %3p%%'])

" ale
let g:ale_linters = {'python': ['pylint']}
let g:ale_python_pylint_options = "--rcfile ~/.pylintrc"

" ripgrep
if executable('rg')
  " Use rg over grep
  set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case

  " Use rg in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'

  " rg is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0

    " bind \ (backward slash) to grep shortcut
    command -nargs=+ -complete=file -bar Rg silent! grep! <args>|cwindow|redraw!
    nnoremap \ :Rg<SPACE>
endif
