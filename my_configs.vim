"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => GUI related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Shows Line Numbers
set number

" Opens new tabs to the right of the current tab
set splitright

" Sets the font and encoding for vim-devicons
set encoding=utf8
set guifont=DroidSansMono\ Nerd\ Font:h12

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
colorscheme peaksea

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Mappings for better editing
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Map auto complete of (, ", ', [ in visual mode
vnoremap $1 <esc>`>a)<esc>`<i(<esc>
vnoremap $2 <esc>`>a]<esc>`<i[<esc>
vnoremap $3 <esc>`>a}<esc>`<i{<esc>
vnoremap $$ <esc>`>a"<esc>`<i"<esc>
vnoremap $q <esc>`>a'<esc>`<i'<esc>
vnoremap $e <esc>`>a"<esc>`<i"<esc>

" Map auto complete of (, ", ', [ in insert mode
inoremap $1 ()<esc>i
inoremap $2 []<esc>i
inoremap $3 {}<esc>i
inoremap $4 {<esc>o}<esc>O
inoremap $q ''<esc>i
inoremap $e ""<esc>i

" Different cursors in insert and visual mode
let &t_SI = "\e[5 q"
let &t_EI = "\e[1 q"

" Remember cursor position
augroup vimrc-remember-cursor-position
    autocmd!
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" Persistent folding
augroup auto_save_folds
autocmd!
autocmd BufWinLeave * mkview
autocmd BufWinEnter * silent loadview

" Enables syntax highlighting for groovy
au BufNewfile,BufRead Jenkinsfile setf groovy

" Swap the lines with the next/previous with down/up arrows
xnoremap <silent> <up> :<C-u>call MoveVisualUp()<CR>
xnoremap <silent> <down> :<C-u>call MoveVisualDown()<CR>

" Inserts a blank line with backspace/enter to above/below the current line without loosing cursor position
nnoremap <silent><Enter> :set paste<CR>m`o<Esc>``:set nopaste<CR>
nnoremap <silent><BS> :set paste<CR>m`O<Esc>``:set nopaste<CR>

" Indent with >,< without loosing cursor position
nnoremap > :call Indent(1)<cr>
nnoremap < :call Indent(0)<cr>
vmap < <gv
vmap > >gv

" Maps d and x to black-hole registry
nnoremap x "_x
nnoremap X "_X
nnoremap d "_d
nnoremap D "_D
vnoremap d "_d

" Maps <leader>d to cut depending on the OS
let uname = substitute(system('uname'), '\n', '', '')
if has('unix')
    nnoremap <leader>d ""d
    nnoremap <leader>D ""D
    vnoremap <leader>d ""d

else
    set clipboard=unnamed
    nnoremap <leader>d "*d
    nnoremap <leader>D "*D
    vnoremap <leader>d "*d
endif

" Maps / to <space> for faster search
:nnoremap <space> /

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugin Related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => NERDTree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Toggles NERDTree with Ctrl + N
map <silent> <C-n> :NERDTreeToggle<CR>

" Custom window position and size
let g:NERDTreeWinSize=30
let g:NERDTreeWinPos = "left"

" Because of a bug in NERDTree
let g:NERDTreeDirArrows = 1
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let g:NERDTreeGlyphReadOnly = "RO"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => NERDCommenter
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Makes toggling comments better
vmap <leader><Space> <plug>NERDCommenterTogglegv
nmap <leader><Space> <plug>NERDCommenterToggle^

" Makes commenting and uncommenting in visual mode to stay in visual mode
vmap <leader>cc <plug>nerdcommentercommentgv
vmap <leader>cu <plug>nerdcommenteruncommentgv

"Makes commenting and uncommenting in normal mode to go to next line
nmap <leader>cc <plug>NERDCommenterCommentj^
nmap <leader>cu <plug>NERDCommenterUncommentj^

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
" Use up and down arrows to swap lines"""
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
"nnoremap <silent> <up> :<C-u>call MoveLineUp()<CR>
"nnoremap <silent> <down> :<C-u>call MoveLineDown()<CR>
"inoremap <silent> <up> <C-o>:call MoveLineUp()<CR>
"inoremap <silent> <down> <C-o>:call MoveLineDown()<CR>
