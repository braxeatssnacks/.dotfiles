" a nice lil' (neo)vim config
" (requires python3 install)

" safety first
set secure

" install vim plug if not installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

"""""""""""""""""""""""" PLUGINS
set runtimepath^=~/.vim/plugin
set runtimepath^=~/.opam/system/share/ocp-indent/vim
call plug#begin('~/.vim/plugged')
  " quote/bracket/tags
  Plug 'tpope/vim-surround'

  " autoclose
  Plug 'townk/vim-autoclose'
  Plug 'tpope/vim-endwise'

  " commenting
  Plug 'tomtom/tcomment_vim'

  " isolated view
  Plug 'chrisbra/NrrwRgn'

  " highlighting
  Plug 'kien/rainbow_parentheses.vim'

  " git gutter
  Plug 'airblade/vim-gitgutter'

  " byobu-esque
  Plug 'bling/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

  " smart '/' search
  Plug 'pgdouyon/vim-evanesco'

  " fuzzy file search
  Plug 'ctrlpvim/ctrlp.vim', { 'do': ':UpdateRemotePlugins' }

  " nerdtree
  Plug 'scrooloose/nerdtree'

  " autocompletion
  if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    Plug 'fishbullet/deoplete-ruby'
  else
    silent !pip3 install neovim
    Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
  endif

  " supertab (for autocompletion)
  Plug 'ervandew/supertab'

  " ruby
  Plug 'vim-ruby/vim-ruby'

  " javascript
  Plug 'ternjs/tern_for_vim'
  Plug 'pangloss/vim-javascript'
  Plug 'mxw/vim-jsx'
  Plug 'moll/vim-node'

call plug#end()

" allow autocompletion
let g:deoplete#enable_at_startup=1
" Enter maps to completion
let g:SuperTabCrMapping = 1
let g:SuperTabDefaultCompletionType = "<c-n>"

" allow closetags
let g:closetag_filenames = "*.html,*.xhtml,*.phtml,*.xml,*.php,*.jsx"

" ctrl-P configs - silver searcher override later
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_user_command = 'find %s -type f'
let g:ctrlp_root_markers = ['\.ctrlp$', '\.git$']
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\.git$\|\.yardoc\|log\|node_modules',
  \ 'file': '\.so$\|\.dat$|\.DS_Store$\|\.ctrlp$'
  \ }

" nerdtree configs
let NERDTreeRespectWildIgnore=1
augroup nerdtree_configs
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
augroup END

" rainbow parentheses
augroup parentheses_configs
  autocmd VimEnter * RainbowParenthesesToggle
  autocmd Syntax * RainbowParenthesesLoadRound
  autocmd Syntax * RainbowParenthesesLoadSquare
  autocmd Syntax * RainbowParenthesesLoadBraces
augroup END

" byobu style
let g:airline_theme="monochrome"

" gitgutter
highlight clear SignColumn
highlight GitGutterAdd ctermfg=green
highlight GitGutterChange ctermfg=yellow
highlight GitGutterDelete ctermfg=red
highlight GitGutterChangeDelete ctermfg=red
let g:gitgutter_max_signs = 500  " keep vim snappy
let g:gitgutter_sign_modified_removed = '≈'
let g:gitgutter_sign_removed_first_line = '↑'

" silver searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
  " Use ag in ctrlp for listing files.
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  " fast enough to not cache
  let g:ctrlp_use_caching = 0
endif

" tern
augroup tern_js_config
  au!
  au CompleteDone * pclose
augroup END

"""""""""""""""""""""""" CONFIGS

" safety first
set nocompatible
" make redraw quick
set ttyfast
" enable mouse!
set mouse=a
" enable line numbers
set number
" keep at least one line above cursor
set scrolloff=1
" copy+paste
set clipboard=unnamed
" ignore case when searching except when search includes uppercase
set ignorecase
set smartcase
" detect when file is changed
set autoread
" ignore
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,.DS_Store
" allow unsaved buffers to go into the background
set hidden

" don't clutter cwd with backup and swap files
set backupdir^=~/.vim/.backup
" '//' incorporate full path into swap filenames
set dir ^=~/.vim/.backup//
" persistent undo (through file)
silent !mkdir ~/.vim/.undo > /dev/null 2>&1
set undodir=~/.vim/.undo
set undofile
" prevent creation of backup & swap files
set nobackup
set noswapfile
set nowb

" default replace tab with 2 spaces
filetype plugin indent on
set tabstop=2
set shiftwidth=2
set expandtab
" automatic config on filetype
augroup filetype_configs
  " ... not for makefiles tho
  autocmd FileType make setlocal noexpandtab
  autocmd FileType makefile setlocal noexpandtab
  " .txt
  autocmd FileType text setlocal autoindent expandtab softtabstop=2
  " .help
  autocmd FileType help setlocal nospell
  " turn off autocomment
  autocmd FileType * set fo-=r fo-=o
augroup END

" split panes lookin nice
set fillchars+=vert:\$
hi VertSplit cterm=NONE ctermbg=NONE ctermfg=NONE
set splitbelow
set splitright

" colors in this bitch
syntax on
highlight LineNr ctermfg=black
highlight Comment ctermfg=grey

" cursor
set cursorline
highlight CursorLine cterm=NONE
highlight Visual cterm=NONE ctermbg=black ctermfg=blue
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175
highlight TermCursor ctermfg=red guifg=red " terminal cursor is red

" automatic commands run on sys task
augroup sys_tasks
  " remove trailing space on save
  autocmd BufWritePre * :%s/\s\+$//e
  " resize splits on window resize
  autocmd VimResized * wincmd =
augroup END


"""""""""""""""""""""""" MACROS + REMAPS

" leader key
let g:mapleader = "\<SPACE>"

" vertical split quick open/close
nnoremap <silent> vv <C-w>v
nnoremap <silent> qq <C-w>q

" pane switches
" vertical
nnoremap <C-J> <C-W><C-W>
nnoremap <C-K> <C-W><C-W>
" horizontal
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" buffer switches
nnoremap <Tab> :bprevious<CR>
nnoremap <S-Tab> :bnext<CR>
" open buffers
nnoremap <leader>bb :Buffers<CR>
" buffer kill
nnoremap <leader>bk :bprevious <BAR> bdelete #<CR>
" close all other buffers
nnoremap <leader>bo :BufOnly<CR>

" press spacebar to remove highlight from current search
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" search for word under the cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" open file path in a split
nnoremap vgf <C-W>v<C-W>lgf
nnoremap sgf <C-W>s<C-W>jgf

" toggle directory view sidebar
map <C-n> :NERDTreeToggle<CR>

" neovim
if has('nvim')
  " terminal
  tnoremap <Esc> <C-\><C-n>
  augroup terminal_tasks
    " remove line numbers in terminal
    autocmd TermOpen * setlocal nonumber norelativenumber
    autocmd TermOpen * startinsert
  augroup END
endif

" macvim
if has("gui_macvim")
  " don't remap anything
  let macvim_skip_cmd_opt_movement=1
  " visual defualts
  set guioptions=egmt
  set antialias
  set fuoptions=maxvert,maxhorz
endif

