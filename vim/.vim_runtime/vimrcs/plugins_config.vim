let uname = substitute(system('uname'), '\n', '', '')
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Load pathogen paths
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:vim_runtime = expand('<sfile>:p:h')."/.."
call pathogen#infect(s:vim_runtime.'/sources_forked/{}')
call pathogen#infect(s:vim_runtime.'/sources_non_forked/{}')
call pathogen#infect(s:vim_runtime.'/my_plugins/{}')
call pathogen#helptags()

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

let s:base2 = [ '#a8a8a8', 248 ]
let s:base02 = [ '#444444 ', 238 ]
let s:base023 = [ '#353535 ', 236 ]
let s:base1 = [ '#969696', 247 ]
let s:base01 = [ '#585858', 240 ]
let s:base0 = [ '#808080', 244 ]
let s:base03 = [ '#242424', 235 ]
let s:base3 = [ '#d0d0d0', 252 ]
let s:yellow = [ '#cae682', 180 ]
let s:red = [ '#e5786d', 203 ]
let s:blue = [ '#8ac6f2', 117 ]
let s:green = [ '#95e454', 119 ]
let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}
let s:p.normal.left = [ [ s:base02, s:blue ], [ s:base3, s:base01 ] ]
let s:p.normal.right = [ [ s:base02, s:base0 ], [ s:base1, s:base01 ] ]
let s:p.normal.middle = [ [ s:base2, s:base02 ] ]
let s:p.normal.error = [ [ s:base03, s:red ] ]
let s:p.normal.warning = [ [ s:base023, s:yellow ] ]
let g:lightline#colorscheme#wombat#palette = lightline#colorscheme#flatten(s:p)
