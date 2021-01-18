#### Installation:
```shell
make personal -B
```
#### Super fast minimal installation
curl -sS https://raw.githubusercontent.com/dgokcin/dotfiles/master/vim/.vim_runtime/vimrcs/minimal.vim >> ~/.vimrc

#### Adding a new plugin:
```shell
cd vim/.vim_runtime/sources_non_forked
git submodule add <git@....>
```
#### Adding the existing vim plugins:
```shell
make update-plugins
```
