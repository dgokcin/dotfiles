# dotfiles

#### Requirements
- vim
- git

#### Installation
```shell
make
```

#### Super fast minimal installation
```shell
curl -sS https://raw.githubusercontent.com/dgokcin/dotfiles/master/.vim_runtime/vimrcs/minimal.vim >> ~/.vimrc
```

#### Adding a new plugin
```shell
cd .vim_runtime/sources_non_forked
git submodule add <git@....>
```

#### Update the existing vim plugins
```shell
make update-plugins
```
