#### Installation:
```shell
make personal -B
```

#### Adding a new plugin:
```shell
cd vim/.vim_runtime/sources_non_forked
git submodule add <git@....>
```
#### Adding the existing vim plugins:
```shell
make update-plugins
```
