" General settings
set number
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
syntax enable

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

" Maps / to <space> for faster search
nnoremap <space> /

" Helper functions
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

