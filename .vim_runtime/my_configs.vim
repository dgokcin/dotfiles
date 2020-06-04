"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Leader
let mapleader = ","

" Determines the OS
let uname = substitute(system('uname'), '\n', '', '')

" Search down into subfolders, provide also tab-completion
set path+=**
set wildmenu

" Sets how many lines of history VIM has to remember
set history=1000

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
" => GUI related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
"augroup filetype_yaml
    "autocmd!
    "autocmd BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml foldmethod=indent
    "autocmd FileType yaml |
        "setlocal shiftwidth=2 |
        "setlocal softtabstop=2 |
        "setlocal tabstop=2
"augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Mappings and configurations for better vi
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maps <leader>f formatting paragraph, without loosing the cursor position
noremap <leader>f gwap

" Makes working with long lines easier, without breaking 5j, 5k behaviour
nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

" Clears highlights on hitting esc twice
nnoremap <esc><esc> :noh<return>

" Maps / to <space> for faster search
nnoremap <space> /

" Disable auto-comment insertion
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

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

" Paste without yanking
vnoremap p "_dP

" Maps <leader>d to visual in word
:map <leader>w viw


" Maps leader yank to copy to system clipboard.
" Works only hasclipboard is true
noremap <leader>y "*y
noremap <leader>Y "*+y
noremap <leader>p "*p
noremap <leader>P "+p

" Maps <leader>d to cut depending on the OS
if uname == 'Darwin'
    nnoremap <leader>d ""d
    nnoremap <leader>D ""D
    vnoremap <leader>d ""d
else
    nnoremap <leader>d "*d
    nnoremap <leader>D "*D
    vnoremap <leader>d "*d
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugin Related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VimCompletesMe
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto complete with tab in insert mode
autocmd FileType vim let b:vcm_tab_complete = 'vim'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => NERDTree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:NERDTreeWinSize=30
let g:NERDTreeWinPos = "left"

" Toggles NERDTree with Ctrl + N
map <silent> <C-n> :NERDTreeToggle<CR>

" Because of a bug in NERDTree
let g:NERDTreeDirArrows = 1
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let g:NERDTreeGlyphReadOnly = "RO"

" Switch between tabs with shift and direction
nmap <S-j> <C-W>j
nmap <S-h> <C-W>h
nmap <S-l> <C-W>l
nmap <S-k> <C-W>k

" Show hidden files by default
let NERDTreeShowHidden=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => NERDCommenter
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Makes toggling comments better
vmap <leader><Space> <plug>NERDCommenterTogglegv
nmap <leader><Space> <plug>NERDCommenterToggle^

" Makes commenting and uncommenting in visual mode to stay in visual mode
vmap <leader>cc <plug>nerdcommentercommentgv
vmap <leader>cu <plug>nerdcommenteruncommentgv

" Makes commenting and uncommenting in normal mode to go to next line
" Ctrl + / for windows
if uname == 'Darwin'
    nmap <leader>cc <plug>NERDCommenterCommentj^
    nmap <leader>cu <plug>NERDCommenterUncommentj^
else
    nmap <C-_> <plug>NERDCommenterCommentj^
    nmap <leader>cu <plug>NERDCommenterUncommentj^
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-multi-cursor
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:multi_cursor_use_default_mapping=0
let g:multi_cursor_start_word_key      = '<C-c>'
let g:multi_cursor_start_key           = 'g<C-c>'
let g:multi_cursor_select_all_word_key = '<A-c>'
let g:multi_cursor_select_all_key      = 'g<A-c>'
let g:multi_cursor_next_key            = '<C-c>'
let g:multi_cursor_prev_key            = '<C-p>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => lightline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set noshowmode
let g:lightline = {
            \ 'colorscheme': 'wombat',
            \ }

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
" Maps jj to esc
"imap jj <Esc>

"nnoremap <silent> <up> :<C-u>call MoveLineUp()<CR>
"nnoremap <silent> <down> :<C-u>call MoveLineDown()<CR>
"inoremap <silent> <up> <C-o>:call MoveLineUp()<CR>
"inoremap <silent> <down> <C-o>:call MoveLineDown()<CR>

