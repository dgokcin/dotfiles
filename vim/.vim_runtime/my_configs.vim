"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Leader
let mapleader = ","

" Determines the OS
let uname = substitute(system('uname'), '\n', '', '')

" Search down into subfolders, provide also tab-completion
set path+=**

" Sets how many lines of history VIM has to remember
set history=1000

" Set to auto read when a file is changed from the outside
set autoread

" Fast saving
nmap <leader>w :w!<cr>

" :W sudo saves the file 
" (useful for handling the permission-denied error)
command W w !sudo tee % > /dev/null

" Enable filetype plugins
filetype plugin on
filetype indent on

" Disable swap and backup file options
set noswapfile
set nowb

" No annoying sound on errors
set visualbell
set t_vb=
set tm=500

" No annoying sound on errors
set autochdir

" No annoying messages after changing configuration
set shortmess=at
set cmdheight=2

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases 
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch 

" Don't redraw while executing macros (good performance config)
set lazyredraw 

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch 

" How many tenths of a second to blink when matching brackets
set mat=2

" How many tenths of a second to blink when matching brackets
set mat=2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => GUI related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Avoid garbled characters in Chinese language windows OS
let $LANG='en' 
set langmenu=en
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

" Turn on the Wild menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=.git\*,.hg\*,.svn\*
else
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Properly disable sound on errors on MacVim
if has("gui_macvim")
    autocmd GUIEnter * set vb t_vb=
endif

" Add a bit extra margin to the left
set foldcolumn=1
" Shows relative line numbers

set number
set relativenumber

"Always show current position
set ruler

" File extension specific stuff

" Height of the command bar
set cmdheight=2

" Enable syntax highlighting
syntax enable 

" Opens new tabs to the right of the current tab
set splitright

" Sets the font and encoding for vim-devicons
set encoding=utf8

" Disable scrollbars
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L

" Folding
set foldenable 
set foldlevelstart=10 
set foldnestmax=10 
set foldmethod=manual 
set foldcolumn=0

" Colorscheme
set background=dark
if has("gui_running")
    colorscheme peaksea
    "colorscheme darcula
else
    colorscheme peaksea
endif

" Disable underline
set nocursorline

autocmd bufreadpre *.tex setlocal textwidth=80
autocmd bufreadpre *.py setlocal textwidth=80

" Fix yaml indent issues
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Mappings and configurations for better vi
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maps <leader>f formatting paragraph, without loosing the cursor position
noremap <leader>f gwap

" Makes working with long lines easier, without breaking 5j, 5k behaviour
if exists('g:vscode')
    nnoremap k :<C-u>call rpcrequest(g:vscode_channel, 'vscode-command', 'cursorMove', { 'to': 'up', 'by': 'wrappedLine', 'value': v:count ? v:count : 1 })<CR>
    nnoremap j :<C-u>call rpcrequest(g:vscode_channel, 'vscode-command', 'cursorMove', { 'to': 'down', 'by': 'wrappedLine', 'value': v:count ? v:count : 1 })<CR>
else
    nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
    nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'
endif


" Clears highlights on hitting esc twice
nnoremap <esc><esc> :noh<return>

" Maps / to <space> for faster search
nnoremap <space> /

" Disable auto-comment insertion
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
autocmd FileType * setlocal foldcolumn=0

" Enable persistent undo.
try
    set undodir=~/.vim_runtime/temp_dirs/undodir
    set undofile
catch
endtry

" Disable arrow keys in normal mode
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" Different cursors in insert and visual mode
let &t_SI = "\e[5 q"
let &t_EI = "\e[1 q"

" move to beginning/end of line 
nnoremap <Tab> $
nnoremap <S-Tab> ^

" Remember cursor position
augroup vimrc-remember-cursor-position
    autocmd!
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" Enables relative numbers in normal mode
augroup toggle_relative_number
    autocmd InsertEnter * :setlocal norelativenumber
    autocmd InsertLeave * :setlocal relativenumber
augroup END

" Persistent folding
augroup auto_save_folds
    autocmd!
    autocmd BufWinLeave ?* mkview
    autocmd BufWinEnter ?* silent loadview
augroup END

" Enables syntax highlighting for groovy
au BufNewfile,BufRead Jenkinsfile setf groovy

" Move lines up and down without loosing the cursor position
vnoremap J :<C-u>call MoveVisualDown()<CR>
vnoremap K :<C-u>call MoveVisualUp()<CR>

" Swap words without loosing cursor position
nnoremap <silent> gl "_yiw?\w\+\_W\+\%#<CR>:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR><c-o><c-l>:nohlsearch<CR>
nnoremap <silent> gr "_yiw:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR><c-o>/\w\+\_W\+<CR><c-l>:nohlsearch<CR>


" Inserts a blank line with backspace/enter to above/below the current line without loosing cursor position
nnoremap <silent><Enter> :set paste<CR>m`o<Esc>``:set nopaste<CR>
nnoremap <silent><BS> :set paste<CR>m`O<Esc>``:set nopaste<CR>

" Indent with >,< without loosing cursor position
nnoremap > :call Indent(1)<cr>
nnoremap < :call Indent(0)<cr>
vmap < <gv
vmap > >gv

" Fix indentation in entire file, get the cursor back to where it was, and put the current line in the middle of your window.
nnoremap _ gg=G``zz
vmap _ gg=G``zz

" Maps d and x to black-hole registry
nnoremap x "_x
nnoremap X "_X
nnoremap d "_d
nnoremap D "_D
vnoremap d "_d

" Maps leader yank to copy to system clipboard.
" Works only hasclipboard is true
noremap <leader>y "*y
noremap <leader>Y "*+y
noremap <leader>p "*p
noremap <leader>P "+p

" Maps <leader>d to cut depending on the OS
nnoremap <leader>d ""d
nnoremap <leader>D ""D
vnoremap <leader>d ""d

" Paste without yanking
vnoremap p "_dP

" Maps <leader>d to visual in word
:map <leader>w viw

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Moves lines up and down, while keeping the cursor pos
function! MoveLineUp()
    call MoveLineOrVisualUp(".", "")
endfunction

function! MoveLineDown()
    call MoveLineOrVisualDown(".", "")
endfunction

function! MoveVisualUp()
    call MoveLineOrVisualUp("'<", "'<,'>")
    normal gv
endfunction

function! MoveVisualDown()
    call MoveLineOrVisualDown("'>", "'<,'>")
    normal gv
endfunction

function! MoveLineOrVisualUp(line_getter, range)
    let l_num = line(a:line_getter)
    if l_num - v:count1 - 1 < 0
        let move_arg = "0"
    else
        let move_arg = a:line_getter." -".(v:count1 + 1)
    endif
    call MoveLineOrVisualUpOrDown(a:range."move ".move_arg)
endfunction

function! MoveLineOrVisualDown(line_getter, range)
    let l_num = line(a:line_getter)
    if l_num + v:count1 > line("$")
        let move_arg = "$"
    else
        let move_arg = a:line_getter." +".v:count1
    endif
    call MoveLineOrVisualUpOrDown(a:range."move ".move_arg)
endfunction

function! MoveLineOrVisualUpOrDown(move_arg)
    let col_num = virtcol(".")
    execute "silent! ".a:move_arg
    execute "normal! ".col_num."|"
endfunction

" Indent with keeping the cursor position
func! Indent(ind)
    if &sol
        set nostartofline
    endif
    let vcol = virtcol('.')
    if a:ind
        norm! >>
        exe "norm!". (vcol + shiftwidth()) . '|'
    else
        norm! <<
        exe "norm!". (vcol - shiftwidth()) . '|'
    endif
endfunc

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Why not?
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Q! q!
cnoreabbrev q1 q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qal

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Not sure
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Spell checking
map <leader>ss :setlocal spell!<cr>

" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Workaround
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:openVSCodeCommandsInVisualMode()
    normal! gv
    let visualmode = visualmode()
    if visualmode == "V"
        let startLine = line("v")
        let endLine = line(".")
        call VSCodeNotifyRange("workbench.action.showCommands", startLine, endLine, 1)
    else
        let startPos = getpos("v")
        let endPos = getpos(".")
        call VSCodeNotifyRangePos("workbench.action.showCommands", startPos[1], endPos[1], startPos[2], endPos[2], 1)
    endif
endfunction

" workaround for calling command picker in visual mode
xnoremap <silent> <C-P> :<C-u>call <SID>openVSCodeCommandsInVisualMode()<CR>
