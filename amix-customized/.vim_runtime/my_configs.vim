""NERDTree
map <silent> <C-n> :NERDTreeToggle<CR>
let g:NERDTreeWinSize=30
let g:NERDTreeWinPos = "left"
set splitright
" NERDTree setting defaults to work around http://github.com/scrooloose/nerdtree/issues/489"
    let g:NERDTreeDirArrows = 1
    let g:NERDTreeDirArrowExpandable = '▸'
    let g:NERDTreeDirArrowCollapsible = '▾'
    let g:NERDTreeGlyphReadOnly = "RO"

"" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

""Different cursors in insert and visual mode""
let &t_SI = "\e[5 q"
let &t_EI = "\e[1 q"

"" no one is really happy until you have this shortcuts
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
