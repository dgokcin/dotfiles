"" NERDTree Connfigurations""
map <silent> <C-n> :NERDTreeToggle<CR>
let g:NERDTreeWinSize=30
let g:NERDTreeWinPos = "left"
"" Opens new NERDTree tabs to the right of the current tab""
set splitright
"" NERDTree setting defaults to work around http://github.com/scrooloose/nerdtree/issues/489""
    let g:NERDTreeDirArrows = 1
    let g:NERDTreeDirArrowExpandable = '▸'
    let g:NERDTreeDirArrowCollapsible = '▾'
    let g:NERDTreeGlyphReadOnly = "RO"

"" Shows Line Numbers""
set number

""Insert a new line with backspace and enter without insert mode""
nmap <BS> O<Esc>
nmap <Enter> o<Esc>

"""Inserts a blank line with backsace/enter to above/below the current line"""
nnoremap <silent><Enter> :set paste<CR>m`o<Esc>``:set nopaste<CR>
nnoremap <silent><BS> :set paste<CR>m`O<Esc>``:set nopaste<CR>

"""Maps default d to black-hole registry"""
nnoremap x "_x
nnoremap X "_X
nnoremap d "_d
nnoremap D "_D
vnoremap d "_d

"""<leader+d cuts>"""
if has('unix')
    nnoremap <leader>d ""d
    nnoremap <leader>D ""D
    vnoremap <leader>d ""d
elseif has('win32') || has('win64')
  if has('unnamedplus')
    set clipboard=unnamed,unnamedplus
    nnoremap <leader>d "+d
    nnoremap <leader>D "+D
    vnoremap <leader>d "+d
  else
    set clipboard=unnamed
    nnoremap <leader>d "*d
    nnoremap <leader>D "*D
    vnoremap <leader>d "*d
  endif
endif

"" Remember cursor position""
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

""Different cursors in insert and visual mode""
let &t_SI = "\e[5 q"
let &t_EI = "\e[1 q"

"" no one is really happy until you have this shortcuts""
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

"" Enables syntax highlighting for Jenkinsfile""
au BufNewfile,BufRead Jenkinsfile setf groovy
