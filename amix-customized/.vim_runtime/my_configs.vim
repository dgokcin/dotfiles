""" NERDTree Configs """
map <silent> <C-n> :NERDTreeToggle<CR>
let g:NERDTreeWinSize=30
let g:NERDTreeWinPos = "left"
set splitright
" NERDTree setting defaults to work around http://github.com/scrooloose/nerdtree/issues/489
if has("win32")
    let g:NERDTreeDirArrows = 1
    let g:NERDTreeDirArrowExpandable = '▸'
    let g:NERDTreeDirArrowCollapsible = '▾'
    let g:NERDTreeGlyphReadOnly = "RO"
"*****************************************************************************
"" Abbreviations
"*****************************************************************************
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
cnoreabbrev Qall qall

""Different cursors in insert and visual mode""
let &t_SI = "\e[5 q"
let &t_EI = "\e[1 q"

""Show Line Numbers""
set number

"" Remember cursor position
augroup vimrc-remember-cursor-position
autocmd!
autocmd BufReadPost * if line("'"") > 1 && line("'"") <= line("$") | exe "normal! g`"" | endif
augroup END

""Enables syntax highlighting for Jenkinsfile""
au BufNewFile,BufRead Jenkinsfile setf groovy
