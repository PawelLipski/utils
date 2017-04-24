"""
"   GENERAL
"""
set nocompatible
filetype plugin on

set nobackup
set tabstop=4
set shiftwidth=4
set noexpandtab
set autoindent

set showcmd
set autowrite
set number
set nobackup
set scrolloff=10

" always show status bar
set laststatus=2

" folding
"set foldmethod=syntax
set foldmethod=manual
set foldnestmax=10
set nofoldenable
set foldlevelstart=1

let sh_fold_enabled=1
let vimsyn_folding='af'
let xml_syntax_folding=1

" wildcard tab-completion
set wildmode=longest,list,full
set wildmenu

" file encoding
set fenc=utf8
set enc=utf8

" syntax coloring
syn on

set completeopt=longest,menuone

" recursive cwd search
set path+=**

" persistent undo
if has('undofile')
    set undofile
    set undodir=$HOME/.vim/undo
    set undolevels=1000
    set undoreload=10000
endif

" automatic cwd change for each file
"autocmd BufEnter * silent! lcd %:p:h

" line at 80 chars + highlight lines longer
"if exists('+colorcolumn')
"    set colorcolumn=80
"else
"    au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%80v.\+', -1)
"endif
"
"highlight OverLength ctermbg=red ctermfg=white guibg=#ffd9d9
"autocmd InsertLeave * match OverLength /\%81v.\+/

" fix slight delay after pressing <Esc>O
" http://ksjoberg.com/vim-esckeys.html
set timeout timeoutlen=1000 ttimeoutlen=100

" fix shift-typos :W, :Q
:command! W w
:command! Q q
:command! pf %s/^pick/fixup

"""
"   SYSTEM-SPECIFIC
"""

if has("unix")
    let $CTAGS = 'ctags'

    if $TERM == "xterm-256color" || $TERM == "screen-256color" || $COLORTERM == "gnome-terminal"
        set t_Co=256
   endif
elseif has("win32")
    "set guifont=Source\ Sans\ Pro
    set guifont=Consolas:cEASTEUROPE

    "source $VIMRUNTIME/mswin.vim
    "behave mswin

    cd d:/projects
    "cd /media/sf_D/projects

    " cygwin
    set shell=C:/cygwin/bin/bash
    set shellcmdflag=--login\ -c
    set shellxquote=\"

    let $HOME = $USERPROFILE
    let $VIM = "C:/Program Files (x86)/Vim"
endif

"""
"   USEFUL AUTOCMDS
"""

" EOL whitespaces highlighting
highlight default link EndOfLineSpace ErrorMsg
match EndOfLineSpace / \+$/
autocmd InsertEnter * hi link EndOfLineSpace Normal
autocmd InsertLeave * hi link EndOfLineSpace ErrorMsg

"""
"   CODE COMPLETION
"""

set ofu=syntaxcomplete#Complete

function! CleverTab()
    if pumvisible()
        return "\<C-N>"
    endif
    if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$'
        return "\<Tab>"
    elseif exists('&omnifunc') && &omnifunc != ''
        return "\<C-X>\<C-O>"
    else
        return "\<C-N>"
    endif
endfunction

inoremap <Tab> <C-R>=CleverTab()<CR>

" Typos
cabbr Lwq wq
cabbr qw wq
cabbr swq wq
cabbr Wq wq

autocmd BufRead,BufNewFile *.rb set filetype=ruby
autocmd BufRead,BufNewFile Vagrantfile set filetype=ruby

