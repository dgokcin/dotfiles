"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => GUI related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Shows Line Numbers
set number

" Opens new tabs to the right of the current tab
set splitright

" Disable scrollbars
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L

" Colorscheme
set background=dark
colorscheme peaksea

" Different cursors in insert and visual mode
let &t_SI = "\e[5 q"
let &t_EI = "\e[1 q"

" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Mappings for better editing
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Inserts a blank line with backspace/enter to above/below the current line without loosing cursor position
nnoremap <silent><Enter> :set paste<CR>m`o<Esc>``:set nopaste<CR>
nnoremap <silent><BS> :set paste<CR>m`O<Esc>``:set nopaste<CR>

" Indent with >,< and TAB, Shift-Tab without loosing cursor position
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
if has('unix')
    nnoremap <leader>d ""d
    nnoremap <leader>D ""D
    vnoremap <leader>d ""d
"elseif has('win32') || has('win64')
  "if has('unnamedplus')
    "set clipboard=unnamed,unnamedplus
    "nnoremap <leader>d "+d
    "nnoremap <leader>D "+D
    "vnoremap <leader>d "+d
  "else
    "set clipboard=unnamed
    "nnoremap <leader>d "*d
    "nnoremap <leader>D "*D
    "vnoremap <leader>d "*d
  "endif
endif

" Maps / to <space> for faster search
:nnoremap <space> /

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugin Related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => NERDTree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
vmap <leader>cc <plug>NERDCommenterCommentgv
vmap <leader>cu <plug>NERDCommenterUncommentgv

 "Makes commenting and uncommenting in normal mode to go to next line
nmap <leader>cc <plug>NERDCommenterCommentj^
nmap <leader>cu <plug>NERDCommenterUncommentj^

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
" Use up and down arrows to switch lines"""
"nnoremap <up> ddkP
"nnoremap <down> ddp
