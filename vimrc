
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'

Plugin 'bling/vim-airline'
Plugin 'ervandew/supertab'
Plugin 'flazz/vim-colorschemes.git'
Plugin 'luochen1990/rainbow'
Plugin 'pearofducks/ansible-vim'
Plugin 'plasticboy/vim-markdown'
Plugin 'rking/ag.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-dispatch'
Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-projectionist'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'

call vundle#end()
filetype plugin indent on

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Settings

set autoindent
set autoread " auto read when a file has changed
set autowrite
set backspace=2
set directory=$HOME/.vim/tmp
set expandtab
set foldmethod=marker
set grepformat=%f:%l:%m
set grepprg=ack
set guioptions-=L
set guioptions-=R
set guioptions-=T
set guioptions-=l
set guioptions-=m
set guioptions-=r
set hidden
set hlsearch
set ignorecase " case insensitive search
set incsearch
set laststatus=2 " always show status line
set lazyredraw
set listchars=tab:+-,trail:-,extends:>,precedes:<,eol:.
set modeline
set mouse=n
set noerrorbells
set nofoldenable
set novisualbell
set nowrap
set scrolloff=5 " keep five lines of scrolling context
set shiftwidth=2
set showmatch
set smartindent
set softtabstop=2
set tags+=./tags,../tags,../../tags,../../../tags,../../../../tags,../../../../../tags
set title
set wildmenu
set wildmode=longest:full,full

if &term == "screen" || &term == "screen-bce" || &term == "screen-256color"
  set notitle
  set t_ts=k
  set t_fs=\
endif

"" Clojure

let g:clojure_fuzzy_indent = 1
let g:clojure_fuzzy_indent_patterns =
      \ ['^def', '^fa-icon$', '^go-', '^html$', '^let', '^query$', '^this-as$', '^using', '^when', '^with']
let g:clojure_fuzzy_indent_blacklist =
      \ ['-fn$', '\v^with-%(meta|out-str|loading-context)$']

" Plugins

" Bufexplorer
let g:bufExplorerDefaultHelp=0
let g:bufExplorerShowRelativePath=1
let g:bufExplorerDisableDefaultKeyMapping=1

" BufStop
let g:BufstopAutoSpeedToggle = 1
let g:BufstopSplit = "leftabove"

" CtrlP
let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

" Markdown
let g:vim_markdown_folding_disabled = 1

" NERDTree
let g:NERDTreeCaseSensitiveSort=1
let g:NERDTreeChDirMode=2
let g:NERDTreeWinSize=30

" SuperTab
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabCompletionContexts = ['s:ContextText', 's:ContextDiscover']
let g:SuperTabContextTextOmniPrecedence = ['&omnifunc', '&completefunc']
let g:SuperTabContextDiscoverDiscovery = ["&omnifunc:<c-x><c-o>", "&completefunc:<c-x><c-u>"]
let g:SuperTabClosePreviewOnPopupClose = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Commands and Functions

function! CurDir()
  let curdir = substitute(getcwd(), '/home/djwhitt', "~", "g")
  return curdir
endfunction

" from http://www.amix.dk/vim/vimrc.html
function! DeleteTrailingWS()
  normal mz
  %s/\s\+$//ge
  normal `z
endfunction

function! TogglePasteVerbosely()
  if &paste
    set nopaste
    echo "paste mode OFF"
  else
    set paste
    echo "paste mode ON"
  endif
endfunction

function! ClojureContext()
  let extension = expand('%:e')
  if extension == 'cljs'
    return "\<c-x>\<c-u>"
  endif

  let curline = getline('.')
  let cnum = col('.')
  let synname = synIDattr(synID(line('.'), cnum - 1, 1), 'name')
  if curline =~ '(\S\+\%' . cnum . 'c' && synname !~ '\(String\|Comment\)'
    return "\<c-x>\<c-u>"
  endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Mappings

let mapleader=','
let maplocalleader=','

" fast window switching
nmap <silent> <C-k> :wincmd k<cr>
nmap <silent> <C-j> :wincmd j<cr>
nmap <silent> <C-h> :wincmd h<cr>
nmap <silent> <C-l> :wincmd l<cr>

" function keys
imap <silent> <F1> <ESC>
map <silent> <F2> :set nu!<CR>
map <silent> <F3> :set list!<CR>
set pastetoggle=<F4>
map <silent> <F4> :call TogglePasteVerbosely()<cr>
map <silent> <F5> :Run<cr>

" command line editing
cnoremap <C-a> <Home>
cnoremap <C-e> <End>

" folding
nnoremap <silent> <Space> @=(foldlevel('.')?'za':'l')<CR>
vnoremap <Space> zf

" misc
nmap <Leader>a :Ag<space>
nmap <Leader>e :e <C-R>=expand('%:h')<CR>/
nmap <silent> <Leader><Leader> :noh<cr>
nmap <silent> <Leader>d :NERDTreeToggle<cr>
nmap <silent> <Leader>b :CtrlPBuffer<cr>
nmap <silent> <Leader>v :e ~/.vimrc<cr>
vmap <silent> <Leader>s :sort i<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Autocommands

"filetype plugin indent on

augroup Misc
  au!
  au BufWrite * :call DeleteTrailingWS()
augroup END

augroup FTCheck
  au!

  " Clojure
  au BufNewFile,BufRead *.boot    set filetype=clojure
  au BufNewFile,BufRead *.cljs.hl set filetype=clojure
  au BufNewFile,BufRead *.edn     set filetype=clojure

  " Ruby
  au BufNewFile,BufRead *.rake    set filetype=ruby
  au BufNewFile,BufRead Berksfile set filetype=ruby
  au BufNewFile,BufRead Capfile   set filetype=ruby
  au BufNewFile,BufRead Cheffile  set filetype=ruby
  au BufNewFile,BufRead Thorfile  set filetype=ruby
augroup END

augroup FTOptions
  au!
  au FileType * if &omnifunc != '' | call SuperTabChain(&omnifunc, "<c-p>") | endif
  au FileType nerdtree nmap <buffer> <silent> <Leader>b :wincmd w<cr>:CtrlPBuffer<cr>
  au FileType clojure nmap <buffer> <silent> <Leader>r :Eval (reloaded.repl/reset)<cr>
  au FileType clojure let b:SuperTabCompletionContexts = ['ClojureContext'] + g:SuperTabCompletionContexts
  au FileType clojure if &completefunc != '' | call SuperTabChain(&completefunc, "<c-p>") | endif
  "au FileType clojure RainbowParenthesesToggle
  "au FileType clojure RainbowParenthesesLoadRound
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" UI

syntax enable

set bg=dark
set t_Co=256
colorscheme xoria256
"let g:zenburn_high_Contrast=1
"colorscheme zenburn
