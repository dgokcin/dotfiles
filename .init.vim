set runtimepath+=~/.vim_runtime
lua require('init')

source ~/.vim_runtime/vimrcs/minimal.vim
source ~/.vim_runtime/vimrcs/extended.vim
source ~/.vim_runtime/vimrcs/filetypes.vim
source ~/.vim_runtime/vimrcs/plugins_config.vim

try
    source ~/.vim_runtime/my_configs.vim
catch
endtry
