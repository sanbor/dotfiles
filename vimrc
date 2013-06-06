" display improvements
set list
" show indents
set listchars=tab:\.\ ,trail:-
set ruler
set colorcolumn=80
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set number 
set showbreak=>\ 
set wildignore=*.bak,*.pyc,*.swp
set wildmenu
set wildmode=list:longest
set history=1000
inoremap <C-s> <ESC>
vnoremap <C-s> <ESC>
set incsearch
set ignorecase
set hlsearch
  if v:progname =~? "gvim"
    colorscheme murphy
  endif
set runtimepath^=~/.vim/bundle/ctrlp.vim
