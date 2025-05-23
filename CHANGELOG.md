# Changelog

## [3.11.0](https://github.com/dgokcin/dotfiles/compare/v3.10.0...v3.11.0) (2025-04-05)


### Features

* add github mcp integration ([06b4263](https://github.com/dgokcin/dotfiles/commit/06b4263e53fa8281d8c8c93d2ace0a1fcc3b5814))


### Bug Fixes

* enhance the gh pr create command ([8e7711e](https://github.com/dgokcin/dotfiles/commit/8e7711e95cc6deae7c8dc62ddc46644734abba4c))
* force correct timestamp creation in the agile workflow ([4df34c4](https://github.com/dgokcin/dotfiles/commit/4df34c44983d2a4b009e4f10e9afba91bbeed321))
* get rid of unneeded docs ([d765339](https://github.com/dgokcin/dotfiles/commit/d76533913de6566c270adffc0b3dca7e777606eb))
* only output the workflow docs ([cac7628](https://github.com/dgokcin/dotfiles/commit/cac7628eae3df515a31133a48500b253e2df005a))
* optimize agile workflow rule for claude-3.7 ([b30ae3a](https://github.com/dgokcin/dotfiles/commit/b30ae3a1e2df04ea615d60b578641c9d8374bb2f))
* resolve conflicting zsh plugins ([78fcb55](https://github.com/dgokcin/dotfiles/commit/78fcb5582d7c31279c317a15a7e0b406bc60074a))

## [3.10.0](https://github.com/dgokcin/dotfiles/compare/v3.9.0...v3.10.0) (2025-03-24)


### Features

* implement comprehensive lessons learned tracking system ([#168](https://github.com/dgokcin/dotfiles/issues/168)) ([69b836f](https://github.com/dgokcin/dotfiles/commit/69b836f97a01879f1ef3ee2371fa1f5bc05047d0))
* some mcp guidelines ([#173](https://github.com/dgokcin/dotfiles/issues/173)) ([ce879f7](https://github.com/dgokcin/dotfiles/commit/ce879f7f55e335dceb12b6de8876478a2d149336))
* update some lazyvim plugins ([#170](https://github.com/dgokcin/dotfiles/issues/170)) ([6d07026](https://github.com/dgokcin/dotfiles/commit/6d07026e2544a94bc0498aa327e1e2d55c9fa522))

## [3.9.0](https://github.com/dgokcin/dotfiles/compare/v3.8.0...v3.9.0) (2025-02-21)


### Features

* **rules:** add pr creation and commit message standards ([#166](https://github.com/dgokcin/dotfiles/issues/166)) ([a48889e](https://github.com/dgokcin/dotfiles/commit/a48889e6449749d90d3d623c90aa2447de1f09e6))

## [3.8.0](https://github.com/dgokcin/dotfiles/compare/v3.6.0...v3.8.0) (2025-02-20)


### ⚠ BREAKING CHANGES

* **utils:** encode method no longer throws.
* some keybindings have been removed or altered, which may affect user workflows

### Features

* add  to multi cursor event types ([#134](https://github.com/dgokcin/dotfiles/issues/134)) ([fb399ea](https://github.com/dgokcin/dotfiles/commit/fb399ea11de783031d08ac2f54d4235d84599f6e))
* add bufferline plugin ([534eb7c](https://github.com/dgokcin/dotfiles/commit/534eb7c8964f36979180d95d48a9f1fb2a9efaeb))
* add command abbreviations ([a407c62](https://github.com/dgokcin/dotfiles/commit/a407c622efe0457984ffe902f241855ea760d3ec))
* add command to get the parent branch of the current branch ([#129](https://github.com/dgokcin/dotfiles/issues/129)) ([114c2c2](https://github.com/dgokcin/dotfiles/commit/114c2c2fb47f0ceaa6d123f079220dca047272e7))
* add create_pr function ([#58](https://github.com/dgokcin/dotfiles/issues/58)) ([893989e](https://github.com/dgokcin/dotfiles/commit/893989ec1b9d05ec2811e82902532f2c583cd592))
* add functions for handling common nvim typos and PR management ([#63](https://github.com/dgokcin/dotfiles/issues/63)) ([b2fd490](https://github.com/dgokcin/dotfiles/commit/b2fd490a3fedfc726a2cd4d957e36900b723e223))
* add git commit verbose ([25a651e](https://github.com/dgokcin/dotfiles/commit/25a651e1e967a8e1dae32f1deebe3ed8baa2656a))
* add karabiner configuration and update clean task ([#114](https://github.com/dgokcin/dotfiles/issues/114)) ([4007dc1](https://github.com/dgokcin/dotfiles/commit/4007dc15e473ca3e5713bcc74f6a074c6c2832c5))
* add keymaps for C to change without yanking ([#28](https://github.com/dgokcin/dotfiles/issues/28)) ([5fb78ea](https://github.com/dgokcin/dotfiles/commit/5fb78ea1e7adb1edd6b398c6e2429b46d5d3d84c))
* add lazygit config file and makefile target ([7293e04](https://github.com/dgokcin/dotfiles/commit/7293e04a94fa453927157c0c068145067dc73f22))
* add local opt variable and set wrap option in options.lua ([#48](https://github.com/dgokcin/dotfiles/issues/48)) ([0af2c05](https://github.com/dgokcin/dotfiles/commit/0af2c052fed92fea3fee0e6cc7f39c4e3ef1b1a6))
* add new key mappings and improve prompts ([#94](https://github.com/dgokcin/dotfiles/issues/94)) ([dd95ed9](https://github.com/dgokcin/dotfiles/commit/dd95ed976b8ac61295ada14c6f9421340d93748f))
* add new key mappings and improve prompts ([#97](https://github.com/dgokcin/dotfiles/issues/97)) ([c13bce1](https://github.com/dgokcin/dotfiles/commit/c13bce138589eb9d0bd00c9f705039ac19a8df65))
* add nvim config ([0874872](https://github.com/dgokcin/dotfiles/commit/0874872c046154b0fe5410446f15da758500a69a))
* add plan and act modes ([#150](https://github.com/dgokcin/dotfiles/issues/150)) ([e86d638](https://github.com/dgokcin/dotfiles/commit/e86d6382db54052985cd8d394ba8e564ba6bf7fd))
* add substitute plugin ([b86d85e](https://github.com/dgokcin/dotfiles/commit/b86d85e400d78d17443e8b73011698a0e8c7c3c9))
* add toggle terminal keymap for vscode integration ([#100](https://github.com/dgokcin/dotfiles/issues/100)) ([a67f74f](https://github.com/dgokcin/dotfiles/commit/a67f74fc9ba5dd10e600e6857e9bcc07653cc240))
* add updated settings ([e82916c](https://github.com/dgokcin/dotfiles/commit/e82916cf0409f3e7720fd891928834a961e4f34c))
* add vscode plugin to nvim config ([#46](https://github.com/dgokcin/dotfiles/issues/46)) ([18762e0](https://github.com/dgokcin/dotfiles/commit/18762e088c302b38cfaa06db2ebc01df44462946))
* add vscode-specific keymaps and plugin configuration ([#87](https://github.com/dgokcin/dotfiles/issues/87)) ([195d76c](https://github.com/dgokcin/dotfiles/commit/195d76cce3bc9a523a2e5eec7c0f5c8d1d01045d))
* adds v4 UUID to crypto ([#91](https://github.com/dgokcin/dotfiles/issues/91)) ([d6c23f5](https://github.com/dgokcin/dotfiles/commit/d6c23f5c0b8e7d54b72a1891972a44cd69dce677))
* **ci:** add release-please integration ([bc9faf5](https://github.com/dgokcin/dotfiles/commit/bc9faf577a6776cb565783ac468ee0bf08c1c2a9))
* cursor enhancements ([#162](https://github.com/dgokcin/dotfiles/issues/162)) ([3a0530a](https://github.com/dgokcin/dotfiles/commit/3a0530a567dc6fc603fe22029ff187776b891b69))
* customizing fast-cursor-move.nvim ([#34](https://github.com/dgokcin/dotfiles/issues/34)) ([d4f77eb](https://github.com/dgokcin/dotfiles/commit/d4f77eb55a6f70a42e2d412a3ca7d68d9ec260cb))
* disable convert to uppercase and lowercase in visual mode ([#109](https://github.com/dgokcin/dotfiles/issues/109)) ([e9cffd2](https://github.com/dgokcin/dotfiles/commit/e9cffd2a6ca4d0d58d984d4a486c7ae19c1a6e9d))
* disable vi-mode if running inside neovim ([#59](https://github.com/dgokcin/dotfiles/issues/59)) ([44a7e33](https://github.com/dgokcin/dotfiles/commit/44a7e33feb14cbab6e8b2491d5fc03182bf1225b))
* **docs:** implement structured lessons documentation standard ([#163](https://github.com/dgokcin/dotfiles/issues/163)) ([b1f256b](https://github.com/dgokcin/dotfiles/commit/b1f256b6b940e2b86751aa0a47859b4440dc5ffa))
* enable gpg signing ([#149](https://github.com/dgokcin/dotfiles/issues/149)) ([d031724](https://github.com/dgokcin/dotfiles/commit/d031724fd63414bd3b207e3a62bc0719907f5007))
* enable tab completion in nvim-cmp ([95e4472](https://github.com/dgokcin/dotfiles/commit/95e4472ba82dcedce79e18d1a74bb142b998748f))
* enhance CopilotChat.nvim plugin with new features and improvements ([#140](https://github.com/dgokcin/dotfiles/issues/140)) ([7452ca5](https://github.com/dgokcin/dotfiles/commit/7452ca56174fea4a859f386f1f13eee1861d7173))
* enhance git diff context resolution ([#146](https://github.com/dgokcin/dotfiles/issues/146)) ([7101bde](https://github.com/dgokcin/dotfiles/commit/7101bde65f620cbdbdf5f8d0555897d5f689c4f6))
* enhance prompts and add git prune alias ([#122](https://github.com/dgokcin/dotfiles/issues/122)) ([9f068c3](https://github.com/dgokcin/dotfiles/commit/9f068c3b49ca712768646e15c31776790f034a3f))
* enhance telescope-undo and toggleterm ([84ae0c4](https://github.com/dgokcin/dotfiles/commit/84ae0c4bfabd3b3ce8296c3c1e7a427b340ac321))
* **git:** make default branch vim on new repos ([486e470](https://github.com/dgokcin/dotfiles/commit/486e4706cdf0f3cfacabdf5ec8ca51f3f57da919))
* introduce personas to the assistant ([#52](https://github.com/dgokcin/dotfiles/issues/52)) ([2543203](https://github.com/dgokcin/dotfiles/commit/2543203478d1863846d164fd78219faddf711a82))
* introduce task difficulties ([#64](https://github.com/dgokcin/dotfiles/issues/64)) ([88cc721](https://github.com/dgokcin/dotfiles/commit/88cc7219304d51a70b25e7301aec1dfdf9af418d))
* **nvim-tree:** add key mappings for file explorer ([#108](https://github.com/dgokcin/dotfiles/issues/108)) ([73b1643](https://github.com/dgokcin/dotfiles/commit/73b16433e5714273a2307ba30af7971c1ae70264))
* **nvim:** add alpha-nvim plugin ([f88282c](https://github.com/dgokcin/dotfiles/commit/f88282c81fb2458bd241510d0a7ce40bde7cf78d))
* **nvim:** add autopairs plugin ([ff2ab16](https://github.com/dgokcin/dotfiles/commit/ff2ab16e239346d78d2020aacfb1f7292b153cc0))
* **nvim:** add copilot plugin ([e9efcb0](https://github.com/dgokcin/dotfiles/commit/e9efcb0cf74feacdb6a0b2cd1d8bcc9bc0ede698))
* **nvim:** add keymap for exiting terminal mode ([2841178](https://github.com/dgokcin/dotfiles/commit/28411786af8e52895c15d4ca3bb45b9ce3bc738e))
* **nvim:** add noice.nvim for floating terminal ([114dad9](https://github.com/dgokcin/dotfiles/commit/114dad939a528ec439b064a0d08fd96dc8f81acb))
* **nvim:** add persistence.nvim plugin ([582c1a7](https://github.com/dgokcin/dotfiles/commit/582c1a7bdf2fea4aabab398117f3698ae4914d63))
* **nvim:** add telescope git commands ([69a9794](https://github.com/dgokcin/dotfiles/commit/69a9794b01f92b3bccf24a4980a20d70b4bd8e62))
* **nvim:** add telescope-undo plugin ([59a4da9](https://github.com/dgokcin/dotfiles/commit/59a4da9728be325fc6043115e4773e69e8c006b6))
* **nvim:** add terraform and hcl to treesitter ([1c13cb1](https://github.com/dgokcin/dotfiles/commit/1c13cb17e200b5bc3295a263d2edc2e5d0c9ba99))
* **nvim:** add toggleterm and term-edit plugins ([250c289](https://github.com/dgokcin/dotfiles/commit/250c28910ee50ab3e63e8155f1519e0a80e6c462))
* **nvim:** add vscode support for some plugins ([ead1990](https://github.com/dgokcin/dotfiles/commit/ead1990165226fcc5c42dae124d14ea9277f897a))
* **nvim:** add vscode-multi-cursor plugin ([5bab6bb](https://github.com/dgokcin/dotfiles/commit/5bab6bba86979ceafdf7f2bd385e2840ae4b7c00))
* **nvim:** change theme to tokyonight ([25dab30](https://github.com/dgokcin/dotfiles/commit/25dab302149fe53583906039ec1366c88df569d5))
* **nvim:** disable swap files ([5d1b670](https://github.com/dgokcin/dotfiles/commit/5d1b670ebb1f37dc81f041a93d68b3ce7c1a217a))
* **nvim:** enhance git short-log alias ([1a9b45b](https://github.com/dgokcin/dotfiles/commit/1a9b45bba9af13e2471f6cc9626a80d82b48e5f0))
* **nvim:** migrate to lazyvim ([2951aa4](https://github.com/dgokcin/dotfiles/commit/2951aa48922a4ddeede841a940485a9858ec7105))
* **nvim:** remove s keymap from flash.nvim ([5d2ed55](https://github.com/dgokcin/dotfiles/commit/5d2ed55bd0a37ba194b737b3ead7eee12fb0e499))
* replace nvim-comment with comment.nvim ([5f30855](https://github.com/dgokcin/dotfiles/commit/5f3085511515403564292ad60ec9cb8e8cf11f43))
* stop media buttons from starting apple music ([#133](https://github.com/dgokcin/dotfiles/issues/133)) ([d3f68c3](https://github.com/dgokcin/dotfiles/commit/d3f68c35feb996b6ba0789eab334bd5354fbe133))
* update .cursorrules ([#61](https://github.com/dgokcin/dotfiles/issues/61)) ([a01a5eb](https://github.com/dgokcin/dotfiles/commit/a01a5eb4774107211f91744ddfdc80336f078a25))
* update cursor rules and improve markdown handling ([#132](https://github.com/dgokcin/dotfiles/issues/132)) ([19a8801](https://github.com/dgokcin/dotfiles/commit/19a8801421f9acb01a7386b3c64991c77b85ebe1))
* update git configuration setup ([#142](https://github.com/dgokcin/dotfiles/issues/142)) ([f0b6f49](https://github.com/dgokcin/dotfiles/commit/f0b6f493ae89ff055530c19b8ee8ff4f75bf6679))
* update nvim-surround and telescope configurations ([#77](https://github.com/dgokcin/dotfiles/issues/77)) ([66704eb](https://github.com/dgokcin/dotfiles/commit/66704eb997c54c2da09bcc8e7c0cddef704aaa8d))
* update pull request prompt to use commitizen style title ([#73](https://github.com/dgokcin/dotfiles/issues/73)) ([ad84eda](https://github.com/dgokcin/dotfiles/commit/ad84eda89d433157f57d6a43f2db5c9847f4f2db))
* use diff with main branch for pr ([c13bce1](https://github.com/dgokcin/dotfiles/commit/c13bce138589eb9d0bd00c9f705039ac19a8df65))
* **utils:** update encode to support unicode ([d6c23f5](https://github.com/dgokcin/dotfiles/commit/d6c23f5c0b8e7d54b72a1891972a44cd69dce677))
* **vscode:** refactor vscode spevific keymaps ([#89](https://github.com/dgokcin/dotfiles/issues/89)) ([3b424c0](https://github.com/dgokcin/dotfiles/commit/3b424c0a6919fb5ef0b76134dc3f12d7b31c7aca))
* **workflow:** add cursor rules and agile workflow templates ([#161](https://github.com/dgokcin/dotfiles/issues/161)) ([19512ac](https://github.com/dgokcin/dotfiles/commit/19512ac67ea1fe0d2e01ed4efe7ec813cd1e9e29))
* **zsh:** fix boot time problem for zsh ([8f92d37](https://github.com/dgokcin/dotfiles/commit/8f92d37ab9bbe88e80e48598f7f6ddf12690c886))


### Bug Fixes

* add BufRead to plugins for faster startup ([19391d8](https://github.com/dgokcin/dotfiles/commit/19391d8854b74e7b838cc84bc98f8cc5282f98b8))
* **checker:** disable notifications ([015d295](https://github.com/dgokcin/dotfiles/commit/015d295aa7d5abdec0f9f5eebefec047b878d769))
* delete without yanking using register a ([0df3a3b](https://github.com/dgokcin/dotfiles/commit/0df3a3b2a4dfd3384272bf2f54410f8efed1b7fa))
* disable mini.ai plugin ([6d8caa9](https://github.com/dgokcin/dotfiles/commit/6d8caa9b79b4865e3e3bdd7db71c48fe359a3c3d))
* disable vim-illuminate ([631dd70](https://github.com/dgokcin/dotfiles/commit/631dd7089ce30488755a2b6f093631dab33d097e))
* enable lazy loading for toggleterm&term-edit ([0f5c871](https://github.com/dgokcin/dotfiles/commit/0f5c87197ab88a4c766ee157e242f6319e5fb3d7))
* fetch latest changes and update key mappings ([#112](https://github.com/dgokcin/dotfiles/issues/112)) ([0ee3903](https://github.com/dgokcin/dotfiles/commit/0ee3903c68ddceff15e75eaf1047418b6d96790e))
* get rid of linter errors in lsp.lua ([#42](https://github.com/dgokcin/dotfiles/issues/42)) ([6e18583](https://github.com/dgokcin/dotfiles/commit/6e185838846b2f53a17d0555dd7c8b20cdad8b89))
* homebrew path correction ([d1b1777](https://github.com/dgokcin/dotfiles/commit/d1b1777817e9b3b08e44a53589cd2764eec893cd))
* hopefully resolve release please problems ([#157](https://github.com/dgokcin/dotfiles/issues/157)) ([7ad7918](https://github.com/dgokcin/dotfiles/commit/7ad79189799f47ef4f46eeb5e6c85e41994736b6))
* hopefully resolve release pls fuck-up ([#159](https://github.com/dgokcin/dotfiles/issues/159)) ([d9e9708](https://github.com/dgokcin/dotfiles/commit/d9e97082c22092b9c416f594ff23d8c959f6cd71))
* **keymap:** change visual mode 'u' and 'U' keymaps to escape instead of no operation ([#115](https://github.com/dgokcin/dotfiles/issues/115)) ([8af3676](https://github.com/dgokcin/dotfiles/commit/8af367692db4209d7a5922ac5583c65d0ca33c8e))
* **keymap:** separate disabling of convert to uppercase and lowercase in visual mode ([#111](https://github.com/dgokcin/dotfiles/issues/111)) ([88b2722](https://github.com/dgokcin/dotfiles/commit/88b272261bf92a233d8646e2a951816a0ef9e495))
* make vim-visual-multi work with vscode ([fe27d8c](https://github.com/dgokcin/dotfiles/commit/fe27d8ccb646bb51192846f40c79a1fdfbe75abf))
* **nvim-tree:** change open vertical split keymap ([3a3acdf](https://github.com/dgokcin/dotfiles/commit/3a3acdf57f5047a8546a43ef2a606a80f551d610))
* **nvim:** properly disable neo-tree plugin ([31ca60e](https://github.com/dgokcin/dotfiles/commit/31ca60e96da834f4591403f6f542fd2cb0251b1c))
* override vscode-neovim keybindings for j and k ([#32](https://github.com/dgokcin/dotfiles/issues/32)) ([4ad165b](https://github.com/dgokcin/dotfiles/commit/4ad165b2a9d037189bec9f3faaf3e0814664e9b3))
* remove commented-out disabled plugins ([3b424c0](https://github.com/dgokcin/dotfiles/commit/3b424c0a6919fb5ef0b76134dc3f12d7b31c7aca))
* remove desc from keymap ([c304d54](https://github.com/dgokcin/dotfiles/commit/c304d548e022d36402fefe5db6cc9ccd8b659911))
* remove redundant rules from cursor ([#55](https://github.com/dgokcin/dotfiles/issues/55)) ([1d1539f](https://github.com/dgokcin/dotfiles/commit/1d1539fe2693f84f6ede2ac9a1c0be7554d5d165))
* remove unnecessary files ([8844ba6](https://github.com/dgokcin/dotfiles/commit/8844ba673146bbf532ea74d681d5856633b60478))
* rename gitconfig files ([#31](https://github.com/dgokcin/dotfiles/issues/31)) ([ddb7f34](https://github.com/dgokcin/dotfiles/commit/ddb7f347e991f2ae18440df2c6e4595e3d0b6233))
* resolve permission issue with wakatime plugin ([e0455b1](https://github.com/dgokcin/dotfiles/commit/e0455b1542cf5b8165f834bc441f7f4a3d7594e2))
* show shrug in dashboard ([adb4c13](https://github.com/dgokcin/dotfiles/commit/adb4c13b4098a89a843a2a0485697ae3cd8fbc51))
* standardize telescope keymap descriptions ([6751e2e](https://github.com/dgokcin/dotfiles/commit/6751e2e6ee512819a36aa8698d20a9d1ddcfbf6a))
* **telescope-undo:** fix preview height ([bbd1aaf](https://github.com/dgokcin/dotfiles/commit/bbd1aaf9a3b4bf1ec6db02b39440f3f34aa83e89))
* update commit message examples to use multiline strings ([#127](https://github.com/dgokcin/dotfiles/issues/127)) ([fee49ef](https://github.com/dgokcin/dotfiles/commit/fee49ef5268ac4ebe5fd65de0442a1aace28bfe4))
* update gh pr create command example to use commitzen style title ([#105](https://github.com/dgokcin/dotfiles/issues/105)) ([3174d0f](https://github.com/dgokcin/dotfiles/commit/3174d0fba1781bd43a41838a1590e0c9faa0a6a9))
* update git diff command to use origin/main branch ([c13bce1](https://github.com/dgokcin/dotfiles/commit/c13bce138589eb9d0bd00c9f705039ac19a8df65))
* update nvim path, correct symlinks ([#57](https://github.com/dgokcin/dotfiles/issues/57)) ([936f79d](https://github.com/dgokcin/dotfiles/commit/936f79d57f58f78442e55aab53632f6a96ed18ea))
* update release-please action and vscode keybindings ([b68201e](https://github.com/dgokcin/dotfiles/commit/b68201e94565db9ddace814be1797607bb0e4880))
* **utils:** unicode no longer throws exception ([d6c23f5](https://github.com/dgokcin/dotfiles/commit/d6c23f5c0b8e7d54b72a1891972a44cd69dce677))


### Miscellaneous Chores

* **main:** release 2.0.0 ([#158](https://github.com/dgokcin/dotfiles/issues/158)) ([d86743a](https://github.com/dgokcin/dotfiles/commit/d86743abcdc9c46189b268159c3919f9ca775c3f))

## [2.0.0](https://github.com/dgokcin/dotfiles/compare/v1.0.0...v2.0.0) (2025-02-14)


### ⚠ BREAKING CHANGES

* **utils:** encode method no longer throws.
* some keybindings have been removed or altered, which may affect user workflows

### Features

* add  to multi cursor event types ([#134](https://github.com/dgokcin/dotfiles/issues/134)) ([fb399ea](https://github.com/dgokcin/dotfiles/commit/fb399ea11de783031d08ac2f54d4235d84599f6e))
* add bufferline plugin ([534eb7c](https://github.com/dgokcin/dotfiles/commit/534eb7c8964f36979180d95d48a9f1fb2a9efaeb))
* add command abbreviations ([a407c62](https://github.com/dgokcin/dotfiles/commit/a407c622efe0457984ffe902f241855ea760d3ec))
* add command to get the parent branch of the current branch ([#129](https://github.com/dgokcin/dotfiles/issues/129)) ([114c2c2](https://github.com/dgokcin/dotfiles/commit/114c2c2fb47f0ceaa6d123f079220dca047272e7))
* add create_pr function ([#58](https://github.com/dgokcin/dotfiles/issues/58)) ([893989e](https://github.com/dgokcin/dotfiles/commit/893989ec1b9d05ec2811e82902532f2c583cd592))
* add functions for handling common nvim typos and PR management ([#63](https://github.com/dgokcin/dotfiles/issues/63)) ([b2fd490](https://github.com/dgokcin/dotfiles/commit/b2fd490a3fedfc726a2cd4d957e36900b723e223))
* add git commit verbose ([25a651e](https://github.com/dgokcin/dotfiles/commit/25a651e1e967a8e1dae32f1deebe3ed8baa2656a))
* add karabiner configuration and update clean task ([#114](https://github.com/dgokcin/dotfiles/issues/114)) ([4007dc1](https://github.com/dgokcin/dotfiles/commit/4007dc15e473ca3e5713bcc74f6a074c6c2832c5))
* add keymaps for C to change without yanking ([#28](https://github.com/dgokcin/dotfiles/issues/28)) ([5fb78ea](https://github.com/dgokcin/dotfiles/commit/5fb78ea1e7adb1edd6b398c6e2429b46d5d3d84c))
* add lazygit config file and makefile target ([7293e04](https://github.com/dgokcin/dotfiles/commit/7293e04a94fa453927157c0c068145067dc73f22))
* add local opt variable and set wrap option in options.lua ([#48](https://github.com/dgokcin/dotfiles/issues/48)) ([0af2c05](https://github.com/dgokcin/dotfiles/commit/0af2c052fed92fea3fee0e6cc7f39c4e3ef1b1a6))
* add new key mappings and improve prompts ([#94](https://github.com/dgokcin/dotfiles/issues/94)) ([dd95ed9](https://github.com/dgokcin/dotfiles/commit/dd95ed976b8ac61295ada14c6f9421340d93748f))
* add new key mappings and improve prompts ([#97](https://github.com/dgokcin/dotfiles/issues/97)) ([c13bce1](https://github.com/dgokcin/dotfiles/commit/c13bce138589eb9d0bd00c9f705039ac19a8df65))
* add nvim config ([0874872](https://github.com/dgokcin/dotfiles/commit/0874872c046154b0fe5410446f15da758500a69a))
* add plan and act modes ([#150](https://github.com/dgokcin/dotfiles/issues/150)) ([e86d638](https://github.com/dgokcin/dotfiles/commit/e86d6382db54052985cd8d394ba8e564ba6bf7fd))
* add substitute plugin ([b86d85e](https://github.com/dgokcin/dotfiles/commit/b86d85e400d78d17443e8b73011698a0e8c7c3c9))
* add toggle terminal keymap for vscode integration ([#100](https://github.com/dgokcin/dotfiles/issues/100)) ([a67f74f](https://github.com/dgokcin/dotfiles/commit/a67f74fc9ba5dd10e600e6857e9bcc07653cc240))
* add updated settings ([e82916c](https://github.com/dgokcin/dotfiles/commit/e82916cf0409f3e7720fd891928834a961e4f34c))
* add vscode plugin to nvim config ([#46](https://github.com/dgokcin/dotfiles/issues/46)) ([18762e0](https://github.com/dgokcin/dotfiles/commit/18762e088c302b38cfaa06db2ebc01df44462946))
* add vscode-specific keymaps and plugin configuration ([#87](https://github.com/dgokcin/dotfiles/issues/87)) ([195d76c](https://github.com/dgokcin/dotfiles/commit/195d76cce3bc9a523a2e5eec7c0f5c8d1d01045d))
* adds v4 UUID to crypto ([#91](https://github.com/dgokcin/dotfiles/issues/91)) ([d6c23f5](https://github.com/dgokcin/dotfiles/commit/d6c23f5c0b8e7d54b72a1891972a44cd69dce677))
* **ci:** add release-please integration ([bc9faf5](https://github.com/dgokcin/dotfiles/commit/bc9faf577a6776cb565783ac468ee0bf08c1c2a9))
* customizing fast-cursor-move.nvim ([#34](https://github.com/dgokcin/dotfiles/issues/34)) ([d4f77eb](https://github.com/dgokcin/dotfiles/commit/d4f77eb55a6f70a42e2d412a3ca7d68d9ec260cb))
* disable convert to uppercase and lowercase in visual mode ([#109](https://github.com/dgokcin/dotfiles/issues/109)) ([e9cffd2](https://github.com/dgokcin/dotfiles/commit/e9cffd2a6ca4d0d58d984d4a486c7ae19c1a6e9d))
* disable vi-mode if running inside neovim ([#59](https://github.com/dgokcin/dotfiles/issues/59)) ([44a7e33](https://github.com/dgokcin/dotfiles/commit/44a7e33feb14cbab6e8b2491d5fc03182bf1225b))
* enable gpg signing ([#149](https://github.com/dgokcin/dotfiles/issues/149)) ([d031724](https://github.com/dgokcin/dotfiles/commit/d031724fd63414bd3b207e3a62bc0719907f5007))
* enable tab completion in nvim-cmp ([95e4472](https://github.com/dgokcin/dotfiles/commit/95e4472ba82dcedce79e18d1a74bb142b998748f))
* enhance CopilotChat.nvim plugin with new features and improvements ([#140](https://github.com/dgokcin/dotfiles/issues/140)) ([7452ca5](https://github.com/dgokcin/dotfiles/commit/7452ca56174fea4a859f386f1f13eee1861d7173))
* enhance git diff context resolution ([#146](https://github.com/dgokcin/dotfiles/issues/146)) ([7101bde](https://github.com/dgokcin/dotfiles/commit/7101bde65f620cbdbdf5f8d0555897d5f689c4f6))
* enhance prompts and add git prune alias ([#122](https://github.com/dgokcin/dotfiles/issues/122)) ([9f068c3](https://github.com/dgokcin/dotfiles/commit/9f068c3b49ca712768646e15c31776790f034a3f))
* enhance telescope-undo and toggleterm ([84ae0c4](https://github.com/dgokcin/dotfiles/commit/84ae0c4bfabd3b3ce8296c3c1e7a427b340ac321))
* **git:** make default branch vim on new repos ([486e470](https://github.com/dgokcin/dotfiles/commit/486e4706cdf0f3cfacabdf5ec8ca51f3f57da919))
* introduce personas to the assistant ([#52](https://github.com/dgokcin/dotfiles/issues/52)) ([2543203](https://github.com/dgokcin/dotfiles/commit/2543203478d1863846d164fd78219faddf711a82))
* introduce task difficulties ([#64](https://github.com/dgokcin/dotfiles/issues/64)) ([88cc721](https://github.com/dgokcin/dotfiles/commit/88cc7219304d51a70b25e7301aec1dfdf9af418d))
* **nvim-tree:** add key mappings for file explorer ([#108](https://github.com/dgokcin/dotfiles/issues/108)) ([73b1643](https://github.com/dgokcin/dotfiles/commit/73b16433e5714273a2307ba30af7971c1ae70264))
* **nvim:** add alpha-nvim plugin ([f88282c](https://github.com/dgokcin/dotfiles/commit/f88282c81fb2458bd241510d0a7ce40bde7cf78d))
* **nvim:** add autopairs plugin ([ff2ab16](https://github.com/dgokcin/dotfiles/commit/ff2ab16e239346d78d2020aacfb1f7292b153cc0))
* **nvim:** add copilot plugin ([e9efcb0](https://github.com/dgokcin/dotfiles/commit/e9efcb0cf74feacdb6a0b2cd1d8bcc9bc0ede698))
* **nvim:** add keymap for exiting terminal mode ([2841178](https://github.com/dgokcin/dotfiles/commit/28411786af8e52895c15d4ca3bb45b9ce3bc738e))
* **nvim:** add noice.nvim for floating terminal ([114dad9](https://github.com/dgokcin/dotfiles/commit/114dad939a528ec439b064a0d08fd96dc8f81acb))
* **nvim:** add persistence.nvim plugin ([582c1a7](https://github.com/dgokcin/dotfiles/commit/582c1a7bdf2fea4aabab398117f3698ae4914d63))
* **nvim:** add telescope git commands ([69a9794](https://github.com/dgokcin/dotfiles/commit/69a9794b01f92b3bccf24a4980a20d70b4bd8e62))
* **nvim:** add telescope-undo plugin ([59a4da9](https://github.com/dgokcin/dotfiles/commit/59a4da9728be325fc6043115e4773e69e8c006b6))
* **nvim:** add terraform and hcl to treesitter ([1c13cb1](https://github.com/dgokcin/dotfiles/commit/1c13cb17e200b5bc3295a263d2edc2e5d0c9ba99))
* **nvim:** add toggleterm and term-edit plugins ([250c289](https://github.com/dgokcin/dotfiles/commit/250c28910ee50ab3e63e8155f1519e0a80e6c462))
* **nvim:** add vscode support for some plugins ([ead1990](https://github.com/dgokcin/dotfiles/commit/ead1990165226fcc5c42dae124d14ea9277f897a))
* **nvim:** add vscode-multi-cursor plugin ([5bab6bb](https://github.com/dgokcin/dotfiles/commit/5bab6bba86979ceafdf7f2bd385e2840ae4b7c00))
* **nvim:** change theme to tokyonight ([25dab30](https://github.com/dgokcin/dotfiles/commit/25dab302149fe53583906039ec1366c88df569d5))
* **nvim:** disable swap files ([5d1b670](https://github.com/dgokcin/dotfiles/commit/5d1b670ebb1f37dc81f041a93d68b3ce7c1a217a))
* **nvim:** enhance git short-log alias ([1a9b45b](https://github.com/dgokcin/dotfiles/commit/1a9b45bba9af13e2471f6cc9626a80d82b48e5f0))
* **nvim:** migrate to lazyvim ([2951aa4](https://github.com/dgokcin/dotfiles/commit/2951aa48922a4ddeede841a940485a9858ec7105))
* **nvim:** remove s keymap from flash.nvim ([5d2ed55](https://github.com/dgokcin/dotfiles/commit/5d2ed55bd0a37ba194b737b3ead7eee12fb0e499))
* replace nvim-comment with comment.nvim ([5f30855](https://github.com/dgokcin/dotfiles/commit/5f3085511515403564292ad60ec9cb8e8cf11f43))
* stop media buttons from starting apple music ([#133](https://github.com/dgokcin/dotfiles/issues/133)) ([d3f68c3](https://github.com/dgokcin/dotfiles/commit/d3f68c35feb996b6ba0789eab334bd5354fbe133))
* update .cursorrules ([#61](https://github.com/dgokcin/dotfiles/issues/61)) ([a01a5eb](https://github.com/dgokcin/dotfiles/commit/a01a5eb4774107211f91744ddfdc80336f078a25))
* update cursor rules and improve markdown handling ([#132](https://github.com/dgokcin/dotfiles/issues/132)) ([19a8801](https://github.com/dgokcin/dotfiles/commit/19a8801421f9acb01a7386b3c64991c77b85ebe1))
* update git configuration setup ([#142](https://github.com/dgokcin/dotfiles/issues/142)) ([f0b6f49](https://github.com/dgokcin/dotfiles/commit/f0b6f493ae89ff055530c19b8ee8ff4f75bf6679))
* update nvim-surround and telescope configurations ([#77](https://github.com/dgokcin/dotfiles/issues/77)) ([66704eb](https://github.com/dgokcin/dotfiles/commit/66704eb997c54c2da09bcc8e7c0cddef704aaa8d))
* update pull request prompt to use commitizen style title ([#73](https://github.com/dgokcin/dotfiles/issues/73)) ([ad84eda](https://github.com/dgokcin/dotfiles/commit/ad84eda89d433157f57d6a43f2db5c9847f4f2db))
* use diff with main branch for pr ([c13bce1](https://github.com/dgokcin/dotfiles/commit/c13bce138589eb9d0bd00c9f705039ac19a8df65))
* **utils:** update encode to support unicode ([d6c23f5](https://github.com/dgokcin/dotfiles/commit/d6c23f5c0b8e7d54b72a1891972a44cd69dce677))
* **vscode:** refactor vscode spevific keymaps ([#89](https://github.com/dgokcin/dotfiles/issues/89)) ([3b424c0](https://github.com/dgokcin/dotfiles/commit/3b424c0a6919fb5ef0b76134dc3f12d7b31c7aca))
* **zsh:** fix boot time problem for zsh ([8f92d37](https://github.com/dgokcin/dotfiles/commit/8f92d37ab9bbe88e80e48598f7f6ddf12690c886))


### Bug Fixes

* add BufRead to plugins for faster startup ([19391d8](https://github.com/dgokcin/dotfiles/commit/19391d8854b74e7b838cc84bc98f8cc5282f98b8))
* **checker:** disable notifications ([015d295](https://github.com/dgokcin/dotfiles/commit/015d295aa7d5abdec0f9f5eebefec047b878d769))
* delete without yanking using register a ([0df3a3b](https://github.com/dgokcin/dotfiles/commit/0df3a3b2a4dfd3384272bf2f54410f8efed1b7fa))
* disable mini.ai plugin ([6d8caa9](https://github.com/dgokcin/dotfiles/commit/6d8caa9b79b4865e3e3bdd7db71c48fe359a3c3d))
* disable vim-illuminate ([631dd70](https://github.com/dgokcin/dotfiles/commit/631dd7089ce30488755a2b6f093631dab33d097e))
* enable lazy loading for toggleterm&term-edit ([0f5c871](https://github.com/dgokcin/dotfiles/commit/0f5c87197ab88a4c766ee157e242f6319e5fb3d7))
* fetch latest changes and update key mappings ([#112](https://github.com/dgokcin/dotfiles/issues/112)) ([0ee3903](https://github.com/dgokcin/dotfiles/commit/0ee3903c68ddceff15e75eaf1047418b6d96790e))
* get rid of linter errors in lsp.lua ([#42](https://github.com/dgokcin/dotfiles/issues/42)) ([6e18583](https://github.com/dgokcin/dotfiles/commit/6e185838846b2f53a17d0555dd7c8b20cdad8b89))
* homebrew path correction ([d1b1777](https://github.com/dgokcin/dotfiles/commit/d1b1777817e9b3b08e44a53589cd2764eec893cd))
* hopefully resolve release please problems ([#157](https://github.com/dgokcin/dotfiles/issues/157)) ([7ad7918](https://github.com/dgokcin/dotfiles/commit/7ad79189799f47ef4f46eeb5e6c85e41994736b6))
* **keymap:** change visual mode 'u' and 'U' keymaps to escape instead of no operation ([#115](https://github.com/dgokcin/dotfiles/issues/115)) ([8af3676](https://github.com/dgokcin/dotfiles/commit/8af367692db4209d7a5922ac5583c65d0ca33c8e))
* **keymap:** separate disabling of convert to uppercase and lowercase in visual mode ([#111](https://github.com/dgokcin/dotfiles/issues/111)) ([88b2722](https://github.com/dgokcin/dotfiles/commit/88b272261bf92a233d8646e2a951816a0ef9e495))
* make vim-visual-multi work with vscode ([fe27d8c](https://github.com/dgokcin/dotfiles/commit/fe27d8ccb646bb51192846f40c79a1fdfbe75abf))
* **nvim-tree:** change open vertical split keymap ([3a3acdf](https://github.com/dgokcin/dotfiles/commit/3a3acdf57f5047a8546a43ef2a606a80f551d610))
* **nvim:** properly disable neo-tree plugin ([31ca60e](https://github.com/dgokcin/dotfiles/commit/31ca60e96da834f4591403f6f542fd2cb0251b1c))
* override vscode-neovim keybindings for j and k ([#32](https://github.com/dgokcin/dotfiles/issues/32)) ([4ad165b](https://github.com/dgokcin/dotfiles/commit/4ad165b2a9d037189bec9f3faaf3e0814664e9b3))
* remove commented-out disabled plugins ([3b424c0](https://github.com/dgokcin/dotfiles/commit/3b424c0a6919fb5ef0b76134dc3f12d7b31c7aca))
* remove desc from keymap ([c304d54](https://github.com/dgokcin/dotfiles/commit/c304d548e022d36402fefe5db6cc9ccd8b659911))
* remove redundant rules from cursor ([#55](https://github.com/dgokcin/dotfiles/issues/55)) ([1d1539f](https://github.com/dgokcin/dotfiles/commit/1d1539fe2693f84f6ede2ac9a1c0be7554d5d165))
* remove unnecessary files ([8844ba6](https://github.com/dgokcin/dotfiles/commit/8844ba673146bbf532ea74d681d5856633b60478))
* rename gitconfig files ([#31](https://github.com/dgokcin/dotfiles/issues/31)) ([ddb7f34](https://github.com/dgokcin/dotfiles/commit/ddb7f347e991f2ae18440df2c6e4595e3d0b6233))
* resolve permission issue with wakatime plugin ([e0455b1](https://github.com/dgokcin/dotfiles/commit/e0455b1542cf5b8165f834bc441f7f4a3d7594e2))
* show shrug in dashboard ([adb4c13](https://github.com/dgokcin/dotfiles/commit/adb4c13b4098a89a843a2a0485697ae3cd8fbc51))
* standardize telescope keymap descriptions ([6751e2e](https://github.com/dgokcin/dotfiles/commit/6751e2e6ee512819a36aa8698d20a9d1ddcfbf6a))
* **telescope-undo:** fix preview height ([bbd1aaf](https://github.com/dgokcin/dotfiles/commit/bbd1aaf9a3b4bf1ec6db02b39440f3f34aa83e89))
* update commit message examples to use multiline strings ([#127](https://github.com/dgokcin/dotfiles/issues/127)) ([fee49ef](https://github.com/dgokcin/dotfiles/commit/fee49ef5268ac4ebe5fd65de0442a1aace28bfe4))
* update gh pr create command example to use commitzen style title ([#105](https://github.com/dgokcin/dotfiles/issues/105)) ([3174d0f](https://github.com/dgokcin/dotfiles/commit/3174d0fba1781bd43a41838a1590e0c9faa0a6a9))
* update git diff command to use origin/main branch ([c13bce1](https://github.com/dgokcin/dotfiles/commit/c13bce138589eb9d0bd00c9f705039ac19a8df65))
* update nvim path, correct symlinks ([#57](https://github.com/dgokcin/dotfiles/issues/57)) ([936f79d](https://github.com/dgokcin/dotfiles/commit/936f79d57f58f78442e55aab53632f6a96ed18ea))
* update release-please action and vscode keybindings ([b68201e](https://github.com/dgokcin/dotfiles/commit/b68201e94565db9ddace814be1797607bb0e4880))
* **utils:** unicode no longer throws exception ([d6c23f5](https://github.com/dgokcin/dotfiles/commit/d6c23f5c0b8e7d54b72a1891972a44cd69dce677))

## 1.0.0 (2025-02-14)


### ⚠ BREAKING CHANGES

* **utils:** encode method no longer throws.
* some keybindings have been removed or altered, which may affect user workflows

### Features

* add  to multi cursor event types ([#134](https://github.com/dgokcin/dotfiles/issues/134)) ([fb399ea](https://github.com/dgokcin/dotfiles/commit/fb399ea11de783031d08ac2f54d4235d84599f6e))
* add bufferline plugin ([534eb7c](https://github.com/dgokcin/dotfiles/commit/534eb7c8964f36979180d95d48a9f1fb2a9efaeb))
* add command abbreviations ([a407c62](https://github.com/dgokcin/dotfiles/commit/a407c622efe0457984ffe902f241855ea760d3ec))
* add command to get the parent branch of the current branch ([#129](https://github.com/dgokcin/dotfiles/issues/129)) ([114c2c2](https://github.com/dgokcin/dotfiles/commit/114c2c2fb47f0ceaa6d123f079220dca047272e7))
* add create_pr function ([#58](https://github.com/dgokcin/dotfiles/issues/58)) ([893989e](https://github.com/dgokcin/dotfiles/commit/893989ec1b9d05ec2811e82902532f2c583cd592))
* add functions for handling common nvim typos and PR management ([#63](https://github.com/dgokcin/dotfiles/issues/63)) ([b2fd490](https://github.com/dgokcin/dotfiles/commit/b2fd490a3fedfc726a2cd4d957e36900b723e223))
* add git commit verbose ([25a651e](https://github.com/dgokcin/dotfiles/commit/25a651e1e967a8e1dae32f1deebe3ed8baa2656a))
* add karabiner configuration and update clean task ([#114](https://github.com/dgokcin/dotfiles/issues/114)) ([4007dc1](https://github.com/dgokcin/dotfiles/commit/4007dc15e473ca3e5713bcc74f6a074c6c2832c5))
* add keymaps for C to change without yanking ([#28](https://github.com/dgokcin/dotfiles/issues/28)) ([5fb78ea](https://github.com/dgokcin/dotfiles/commit/5fb78ea1e7adb1edd6b398c6e2429b46d5d3d84c))
* add lazygit config file and makefile target ([7293e04](https://github.com/dgokcin/dotfiles/commit/7293e04a94fa453927157c0c068145067dc73f22))
* add local opt variable and set wrap option in options.lua ([#48](https://github.com/dgokcin/dotfiles/issues/48)) ([0af2c05](https://github.com/dgokcin/dotfiles/commit/0af2c052fed92fea3fee0e6cc7f39c4e3ef1b1a6))
* add new key mappings and improve prompts ([#94](https://github.com/dgokcin/dotfiles/issues/94)) ([dd95ed9](https://github.com/dgokcin/dotfiles/commit/dd95ed976b8ac61295ada14c6f9421340d93748f))
* add new key mappings and improve prompts ([#97](https://github.com/dgokcin/dotfiles/issues/97)) ([c13bce1](https://github.com/dgokcin/dotfiles/commit/c13bce138589eb9d0bd00c9f705039ac19a8df65))
* add nvim config ([0874872](https://github.com/dgokcin/dotfiles/commit/0874872c046154b0fe5410446f15da758500a69a))
* add plan and act modes ([#150](https://github.com/dgokcin/dotfiles/issues/150)) ([e86d638](https://github.com/dgokcin/dotfiles/commit/e86d6382db54052985cd8d394ba8e564ba6bf7fd))
* add substitute plugin ([b86d85e](https://github.com/dgokcin/dotfiles/commit/b86d85e400d78d17443e8b73011698a0e8c7c3c9))
* add toggle terminal keymap for vscode integration ([#100](https://github.com/dgokcin/dotfiles/issues/100)) ([a67f74f](https://github.com/dgokcin/dotfiles/commit/a67f74fc9ba5dd10e600e6857e9bcc07653cc240))
* add updated settings ([e82916c](https://github.com/dgokcin/dotfiles/commit/e82916cf0409f3e7720fd891928834a961e4f34c))
* add vscode plugin to nvim config ([#46](https://github.com/dgokcin/dotfiles/issues/46)) ([18762e0](https://github.com/dgokcin/dotfiles/commit/18762e088c302b38cfaa06db2ebc01df44462946))
* add vscode-specific keymaps and plugin configuration ([#87](https://github.com/dgokcin/dotfiles/issues/87)) ([195d76c](https://github.com/dgokcin/dotfiles/commit/195d76cce3bc9a523a2e5eec7c0f5c8d1d01045d))
* adds v4 UUID to crypto ([#91](https://github.com/dgokcin/dotfiles/issues/91)) ([d6c23f5](https://github.com/dgokcin/dotfiles/commit/d6c23f5c0b8e7d54b72a1891972a44cd69dce677))
* **ci:** add release-please integration ([bc9faf5](https://github.com/dgokcin/dotfiles/commit/bc9faf577a6776cb565783ac468ee0bf08c1c2a9))
* customizing fast-cursor-move.nvim ([#34](https://github.com/dgokcin/dotfiles/issues/34)) ([d4f77eb](https://github.com/dgokcin/dotfiles/commit/d4f77eb55a6f70a42e2d412a3ca7d68d9ec260cb))
* disable convert to uppercase and lowercase in visual mode ([#109](https://github.com/dgokcin/dotfiles/issues/109)) ([e9cffd2](https://github.com/dgokcin/dotfiles/commit/e9cffd2a6ca4d0d58d984d4a486c7ae19c1a6e9d))
* disable vi-mode if running inside neovim ([#59](https://github.com/dgokcin/dotfiles/issues/59)) ([44a7e33](https://github.com/dgokcin/dotfiles/commit/44a7e33feb14cbab6e8b2491d5fc03182bf1225b))
* enable gpg signing ([#149](https://github.com/dgokcin/dotfiles/issues/149)) ([d031724](https://github.com/dgokcin/dotfiles/commit/d031724fd63414bd3b207e3a62bc0719907f5007))
* enable tab completion in nvim-cmp ([95e4472](https://github.com/dgokcin/dotfiles/commit/95e4472ba82dcedce79e18d1a74bb142b998748f))
* enhance CopilotChat.nvim plugin with new features and improvements ([#140](https://github.com/dgokcin/dotfiles/issues/140)) ([7452ca5](https://github.com/dgokcin/dotfiles/commit/7452ca56174fea4a859f386f1f13eee1861d7173))
* enhance git diff context resolution ([#146](https://github.com/dgokcin/dotfiles/issues/146)) ([7101bde](https://github.com/dgokcin/dotfiles/commit/7101bde65f620cbdbdf5f8d0555897d5f689c4f6))
* enhance prompts and add git prune alias ([#122](https://github.com/dgokcin/dotfiles/issues/122)) ([9f068c3](https://github.com/dgokcin/dotfiles/commit/9f068c3b49ca712768646e15c31776790f034a3f))
* enhance telescope-undo and toggleterm ([84ae0c4](https://github.com/dgokcin/dotfiles/commit/84ae0c4bfabd3b3ce8296c3c1e7a427b340ac321))
* **git:** make default branch vim on new repos ([486e470](https://github.com/dgokcin/dotfiles/commit/486e4706cdf0f3cfacabdf5ec8ca51f3f57da919))
* introduce personas to the assistant ([#52](https://github.com/dgokcin/dotfiles/issues/52)) ([2543203](https://github.com/dgokcin/dotfiles/commit/2543203478d1863846d164fd78219faddf711a82))
* introduce task difficulties ([#64](https://github.com/dgokcin/dotfiles/issues/64)) ([88cc721](https://github.com/dgokcin/dotfiles/commit/88cc7219304d51a70b25e7301aec1dfdf9af418d))
* **nvim-tree:** add key mappings for file explorer ([#108](https://github.com/dgokcin/dotfiles/issues/108)) ([73b1643](https://github.com/dgokcin/dotfiles/commit/73b16433e5714273a2307ba30af7971c1ae70264))
* **nvim:** add alpha-nvim plugin ([f88282c](https://github.com/dgokcin/dotfiles/commit/f88282c81fb2458bd241510d0a7ce40bde7cf78d))
* **nvim:** add autopairs plugin ([ff2ab16](https://github.com/dgokcin/dotfiles/commit/ff2ab16e239346d78d2020aacfb1f7292b153cc0))
* **nvim:** add copilot plugin ([e9efcb0](https://github.com/dgokcin/dotfiles/commit/e9efcb0cf74feacdb6a0b2cd1d8bcc9bc0ede698))
* **nvim:** add keymap for exiting terminal mode ([2841178](https://github.com/dgokcin/dotfiles/commit/28411786af8e52895c15d4ca3bb45b9ce3bc738e))
* **nvim:** add noice.nvim for floating terminal ([114dad9](https://github.com/dgokcin/dotfiles/commit/114dad939a528ec439b064a0d08fd96dc8f81acb))
* **nvim:** add persistence.nvim plugin ([582c1a7](https://github.com/dgokcin/dotfiles/commit/582c1a7bdf2fea4aabab398117f3698ae4914d63))
* **nvim:** add telescope git commands ([69a9794](https://github.com/dgokcin/dotfiles/commit/69a9794b01f92b3bccf24a4980a20d70b4bd8e62))
* **nvim:** add telescope-undo plugin ([59a4da9](https://github.com/dgokcin/dotfiles/commit/59a4da9728be325fc6043115e4773e69e8c006b6))
* **nvim:** add terraform and hcl to treesitter ([1c13cb1](https://github.com/dgokcin/dotfiles/commit/1c13cb17e200b5bc3295a263d2edc2e5d0c9ba99))
* **nvim:** add toggleterm and term-edit plugins ([250c289](https://github.com/dgokcin/dotfiles/commit/250c28910ee50ab3e63e8155f1519e0a80e6c462))
* **nvim:** add vscode support for some plugins ([ead1990](https://github.com/dgokcin/dotfiles/commit/ead1990165226fcc5c42dae124d14ea9277f897a))
* **nvim:** add vscode-multi-cursor plugin ([5bab6bb](https://github.com/dgokcin/dotfiles/commit/5bab6bba86979ceafdf7f2bd385e2840ae4b7c00))
* **nvim:** change theme to tokyonight ([25dab30](https://github.com/dgokcin/dotfiles/commit/25dab302149fe53583906039ec1366c88df569d5))
* **nvim:** disable swap files ([5d1b670](https://github.com/dgokcin/dotfiles/commit/5d1b670ebb1f37dc81f041a93d68b3ce7c1a217a))
* **nvim:** enhance git short-log alias ([1a9b45b](https://github.com/dgokcin/dotfiles/commit/1a9b45bba9af13e2471f6cc9626a80d82b48e5f0))
* **nvim:** migrate to lazyvim ([2951aa4](https://github.com/dgokcin/dotfiles/commit/2951aa48922a4ddeede841a940485a9858ec7105))
* **nvim:** remove s keymap from flash.nvim ([5d2ed55](https://github.com/dgokcin/dotfiles/commit/5d2ed55bd0a37ba194b737b3ead7eee12fb0e499))
* replace nvim-comment with comment.nvim ([5f30855](https://github.com/dgokcin/dotfiles/commit/5f3085511515403564292ad60ec9cb8e8cf11f43))
* stop media buttons from starting apple music ([#133](https://github.com/dgokcin/dotfiles/issues/133)) ([d3f68c3](https://github.com/dgokcin/dotfiles/commit/d3f68c35feb996b6ba0789eab334bd5354fbe133))
* update .cursorrules ([#61](https://github.com/dgokcin/dotfiles/issues/61)) ([a01a5eb](https://github.com/dgokcin/dotfiles/commit/a01a5eb4774107211f91744ddfdc80336f078a25))
* update cursor rules and improve markdown handling ([#132](https://github.com/dgokcin/dotfiles/issues/132)) ([19a8801](https://github.com/dgokcin/dotfiles/commit/19a8801421f9acb01a7386b3c64991c77b85ebe1))
* update git configuration setup ([#142](https://github.com/dgokcin/dotfiles/issues/142)) ([f0b6f49](https://github.com/dgokcin/dotfiles/commit/f0b6f493ae89ff055530c19b8ee8ff4f75bf6679))
* update nvim-surround and telescope configurations ([#77](https://github.com/dgokcin/dotfiles/issues/77)) ([66704eb](https://github.com/dgokcin/dotfiles/commit/66704eb997c54c2da09bcc8e7c0cddef704aaa8d))
* update pull request prompt to use commitizen style title ([#73](https://github.com/dgokcin/dotfiles/issues/73)) ([ad84eda](https://github.com/dgokcin/dotfiles/commit/ad84eda89d433157f57d6a43f2db5c9847f4f2db))
* use diff with main branch for pr ([c13bce1](https://github.com/dgokcin/dotfiles/commit/c13bce138589eb9d0bd00c9f705039ac19a8df65))
* **utils:** update encode to support unicode ([d6c23f5](https://github.com/dgokcin/dotfiles/commit/d6c23f5c0b8e7d54b72a1891972a44cd69dce677))
* **vscode:** refactor vscode spevific keymaps ([#89](https://github.com/dgokcin/dotfiles/issues/89)) ([3b424c0](https://github.com/dgokcin/dotfiles/commit/3b424c0a6919fb5ef0b76134dc3f12d7b31c7aca))
* **zsh:** fix boot time problem for zsh ([8f92d37](https://github.com/dgokcin/dotfiles/commit/8f92d37ab9bbe88e80e48598f7f6ddf12690c886))


### Bug Fixes

* add BufRead to plugins for faster startup ([19391d8](https://github.com/dgokcin/dotfiles/commit/19391d8854b74e7b838cc84bc98f8cc5282f98b8))
* **checker:** disable notifications ([015d295](https://github.com/dgokcin/dotfiles/commit/015d295aa7d5abdec0f9f5eebefec047b878d769))
* delete without yanking using register a ([0df3a3b](https://github.com/dgokcin/dotfiles/commit/0df3a3b2a4dfd3384272bf2f54410f8efed1b7fa))
* disable mini.ai plugin ([6d8caa9](https://github.com/dgokcin/dotfiles/commit/6d8caa9b79b4865e3e3bdd7db71c48fe359a3c3d))
* disable vim-illuminate ([631dd70](https://github.com/dgokcin/dotfiles/commit/631dd7089ce30488755a2b6f093631dab33d097e))
* enable lazy loading for toggleterm&term-edit ([0f5c871](https://github.com/dgokcin/dotfiles/commit/0f5c87197ab88a4c766ee157e242f6319e5fb3d7))
* fetch latest changes and update key mappings ([#112](https://github.com/dgokcin/dotfiles/issues/112)) ([0ee3903](https://github.com/dgokcin/dotfiles/commit/0ee3903c68ddceff15e75eaf1047418b6d96790e))
* get rid of linter errors in lsp.lua ([#42](https://github.com/dgokcin/dotfiles/issues/42)) ([6e18583](https://github.com/dgokcin/dotfiles/commit/6e185838846b2f53a17d0555dd7c8b20cdad8b89))
* homebrew path correction ([d1b1777](https://github.com/dgokcin/dotfiles/commit/d1b1777817e9b3b08e44a53589cd2764eec893cd))
* **keymap:** change visual mode 'u' and 'U' keymaps to escape instead of no operation ([#115](https://github.com/dgokcin/dotfiles/issues/115)) ([8af3676](https://github.com/dgokcin/dotfiles/commit/8af367692db4209d7a5922ac5583c65d0ca33c8e))
* **keymap:** separate disabling of convert to uppercase and lowercase in visual mode ([#111](https://github.com/dgokcin/dotfiles/issues/111)) ([88b2722](https://github.com/dgokcin/dotfiles/commit/88b272261bf92a233d8646e2a951816a0ef9e495))
* make vim-visual-multi work with vscode ([fe27d8c](https://github.com/dgokcin/dotfiles/commit/fe27d8ccb646bb51192846f40c79a1fdfbe75abf))
* **nvim-tree:** change open vertical split keymap ([3a3acdf](https://github.com/dgokcin/dotfiles/commit/3a3acdf57f5047a8546a43ef2a606a80f551d610))
* **nvim:** properly disable neo-tree plugin ([31ca60e](https://github.com/dgokcin/dotfiles/commit/31ca60e96da834f4591403f6f542fd2cb0251b1c))
* override vscode-neovim keybindings for j and k ([#32](https://github.com/dgokcin/dotfiles/issues/32)) ([4ad165b](https://github.com/dgokcin/dotfiles/commit/4ad165b2a9d037189bec9f3faaf3e0814664e9b3))
* remove commented-out disabled plugins ([3b424c0](https://github.com/dgokcin/dotfiles/commit/3b424c0a6919fb5ef0b76134dc3f12d7b31c7aca))
* remove desc from keymap ([c304d54](https://github.com/dgokcin/dotfiles/commit/c304d548e022d36402fefe5db6cc9ccd8b659911))
* remove redundant rules from cursor ([#55](https://github.com/dgokcin/dotfiles/issues/55)) ([1d1539f](https://github.com/dgokcin/dotfiles/commit/1d1539fe2693f84f6ede2ac9a1c0be7554d5d165))
* remove unnecessary files ([8844ba6](https://github.com/dgokcin/dotfiles/commit/8844ba673146bbf532ea74d681d5856633b60478))
* rename gitconfig files ([#31](https://github.com/dgokcin/dotfiles/issues/31)) ([ddb7f34](https://github.com/dgokcin/dotfiles/commit/ddb7f347e991f2ae18440df2c6e4595e3d0b6233))
* resolve permission issue with wakatime plugin ([e0455b1](https://github.com/dgokcin/dotfiles/commit/e0455b1542cf5b8165f834bc441f7f4a3d7594e2))
* show shrug in dashboard ([adb4c13](https://github.com/dgokcin/dotfiles/commit/adb4c13b4098a89a843a2a0485697ae3cd8fbc51))
* standardize telescope keymap descriptions ([6751e2e](https://github.com/dgokcin/dotfiles/commit/6751e2e6ee512819a36aa8698d20a9d1ddcfbf6a))
* **telescope-undo:** fix preview height ([bbd1aaf](https://github.com/dgokcin/dotfiles/commit/bbd1aaf9a3b4bf1ec6db02b39440f3f34aa83e89))
* update commit message examples to use multiline strings ([#127](https://github.com/dgokcin/dotfiles/issues/127)) ([fee49ef](https://github.com/dgokcin/dotfiles/commit/fee49ef5268ac4ebe5fd65de0442a1aace28bfe4))
* update gh pr create command example to use commitzen style title ([#105](https://github.com/dgokcin/dotfiles/issues/105)) ([3174d0f](https://github.com/dgokcin/dotfiles/commit/3174d0fba1781bd43a41838a1590e0c9faa0a6a9))
* update git diff command to use origin/main branch ([c13bce1](https://github.com/dgokcin/dotfiles/commit/c13bce138589eb9d0bd00c9f705039ac19a8df65))
* update nvim path, correct symlinks ([#57](https://github.com/dgokcin/dotfiles/issues/57)) ([936f79d](https://github.com/dgokcin/dotfiles/commit/936f79d57f58f78442e55aab53632f6a96ed18ea))
* update release-please action and vscode keybindings ([b68201e](https://github.com/dgokcin/dotfiles/commit/b68201e94565db9ddace814be1797607bb0e4880))
* **utils:** unicode no longer throws exception ([d6c23f5](https://github.com/dgokcin/dotfiles/commit/d6c23f5c0b8e7d54b72a1891972a44cd69dce677))

## [3.6.0](https://github.com/dgokcin/dotfiles/compare/v3.5.0...v3.6.0) (2024-09-09)


### Features

* add karabiner configuration and update clean task ([#114](https://github.com/dgokcin/dotfiles/issues/114)) ([4100e44](https://github.com/dgokcin/dotfiles/commit/4100e4468856e24447abc01b1225b79ac9a7dafc))
* enhance prompts and add git prune alias ([#122](https://github.com/dgokcin/dotfiles/issues/122)) ([3525a14](https://github.com/dgokcin/dotfiles/commit/3525a14746d5abce00041d2db6b09ec25fa35343))


### Bug Fixes

* fetch latest changes and update key mappings ([#112](https://github.com/dgokcin/dotfiles/issues/112)) ([48dc110](https://github.com/dgokcin/dotfiles/commit/48dc11037dbdf08fa57a0f420036c2f6c4753375))
* **keymap:** change visual mode 'u' and 'U' keymaps to escape instead of no operation ([#115](https://github.com/dgokcin/dotfiles/issues/115)) ([d7d57b3](https://github.com/dgokcin/dotfiles/commit/d7d57b3580f844e39024ed2befcb0e98dd7c7c8b))
* update commit message examples to use multiline strings ([#127](https://github.com/dgokcin/dotfiles/issues/127)) ([1b2f67d](https://github.com/dgokcin/dotfiles/commit/1b2f67d2426a59d71834c50dcff9115507d1c061))

## [3.5.0](https://github.com/dgokcin/dotfiles/compare/v3.4.0...v3.5.0) (2024-08-26)


### Features

* disable convert to uppercase and lowercase in visual mode ([#109](https://github.com/dgokcin/dotfiles/issues/109)) ([8b1cee2](https://github.com/dgokcin/dotfiles/commit/8b1cee26b6d9e353a1db78509511f2b1d04f48bd))


### Bug Fixes

* **keymap:** separate disabling of convert to uppercase and lowercase in visual mode ([#111](https://github.com/dgokcin/dotfiles/issues/111)) ([5844832](https://github.com/dgokcin/dotfiles/commit/5844832338d003722341bd6e0f34cdefc12090dc))

## [3.4.0](https://github.com/dgokcin/dotfiles/compare/v3.3.0...v3.4.0) (2024-08-25)


### Features

* **nvim-tree:** add key mappings for file explorer ([#108](https://github.com/dgokcin/dotfiles/issues/108)) ([09c8f3e](https://github.com/dgokcin/dotfiles/commit/09c8f3ead3cd71f5c3e98fd08d7a66de8ffe40a9))


### Bug Fixes

* update gh pr create command example to use commitzen style title ([#105](https://github.com/dgokcin/dotfiles/issues/105)) ([237dbe9](https://github.com/dgokcin/dotfiles/commit/237dbe98dac17362f660a642bbf481cdf862d8b9))

## [3.3.0](https://github.com/dgokcin/dotfiles/compare/v3.2.0...v3.3.0) (2024-08-15)


### Features

* add toggle terminal keymap for vscode integration ([#100](https://github.com/dgokcin/dotfiles/issues/100)) ([1892024](https://github.com/dgokcin/dotfiles/commit/1892024f74057d82fffe6fe80e4c8dfe06583ac8))

## [3.2.0](https://github.com/dgokcin/dotfiles/compare/v3.1.0...v3.2.0) (2024-08-12)


### Features

* add new key mappings and improve prompts ([#97](https://github.com/dgokcin/dotfiles/issues/97)) ([61b5aa8](https://github.com/dgokcin/dotfiles/commit/61b5aa874f7872d18537cb5008ef5107e0ebc13f))
* use diff with main branch for pr ([61b5aa8](https://github.com/dgokcin/dotfiles/commit/61b5aa874f7872d18537cb5008ef5107e0ebc13f))


### Bug Fixes

* update git diff command to use origin/main branch ([61b5aa8](https://github.com/dgokcin/dotfiles/commit/61b5aa874f7872d18537cb5008ef5107e0ebc13f))

## [3.1.0](https://github.com/dgokcin/dotfiles/compare/v3.0.0...v3.1.0) (2024-08-12)


### Features

* add new key mappings and improve prompts ([#94](https://github.com/dgokcin/dotfiles/issues/94)) ([1486ac1](https://github.com/dgokcin/dotfiles/commit/1486ac1ea9559b9046911d916368f533de54b243))

## [3.0.0](https://github.com/dgokcin/dotfiles/compare/v2.4.0...v3.0.0) (2024-08-12)


### ⚠ BREAKING CHANGES

* **utils:** encode method no longer throws.

### Features

* adds v4 UUID to crypto ([#91](https://github.com/dgokcin/dotfiles/issues/91)) ([6d19866](https://github.com/dgokcin/dotfiles/commit/6d198664255a3e4c3d06203c475d2251520add11))
* **utils:** update encode to support unicode ([6d19866](https://github.com/dgokcin/dotfiles/commit/6d198664255a3e4c3d06203c475d2251520add11))


### Bug Fixes

* **utils:** unicode no longer throws exception ([6d19866](https://github.com/dgokcin/dotfiles/commit/6d198664255a3e4c3d06203c475d2251520add11))

## [2.4.0](https://github.com/dgokcin/dotfiles/compare/v2.3.0...v2.4.0) (2024-08-12)


### Features

* **vscode:** refactor vscode spevific keymaps ([#89](https://github.com/dgokcin/dotfiles/issues/89)) ([6e09121](https://github.com/dgokcin/dotfiles/commit/6e09121a0f3a1725a847a13f07665c315c0bc6e7))


### Bug Fixes

* remove commented-out disabled plugins ([6e09121](https://github.com/dgokcin/dotfiles/commit/6e09121a0f3a1725a847a13f07665c315c0bc6e7))

## [2.3.0](https://github.com/dgokcin/dotfiles/compare/v2.2.0...v2.3.0) (2024-08-11)


### Features

* add vscode-specific keymaps and plugin configuration ([#87](https://github.com/dgokcin/dotfiles/issues/87)) ([9636b5c](https://github.com/dgokcin/dotfiles/commit/9636b5c0774ca4ac53a90dbbe154cd0ae734b90a))

## [2.2.0](https://github.com/dgokcin/dotfiles/compare/v2.1.0...v2.2.0) (2024-08-10)


### Features

* update nvim-surround and telescope configurations ([#77](https://github.com/dgokcin/dotfiles/issues/77)) ([8b0ae42](https://github.com/dgokcin/dotfiles/commit/8b0ae42bc715bbde1df3d31aa3ef39762f5b2a98))

## [2.1.0](https://github.com/dgokcin/dotfiles/compare/v2.0.0...v2.1.0) (2024-08-08)


### Features

* update pull request prompt to use commitizen style title ([#73](https://github.com/dgokcin/dotfiles/issues/73)) ([acc6a87](https://github.com/dgokcin/dotfiles/commit/acc6a8778e03c39c03ee282369a6c625002b693a))

## [2.0.0](https://github.com/dgokcin/dotfiles/compare/v1.12.0...v2.0.0) (2024-08-05)


### ⚠ BREAKING CHANGES

* some keybindings have been removed or altered, which may affect user workflows

### Bug Fixes

* update release-please action and vscode keybindings ([a8c7852](https://github.com/dgokcin/dotfiles/commit/a8c7852fb9b56749e2d33e1303ef0a8ec232a9e0))

## [1.12.0](https://github.com/dgokcin/dotfiles/compare/v1.11.0...v1.12.0) (2024-07-22)


### Features

* add functions for handling common nvim typos and PR management ([#63](https://github.com/dgokcin/dotfiles/issues/63)) ([2a4870a](https://github.com/dgokcin/dotfiles/commit/2a4870a89be88d86b5d5051bd44ef46b91cd667f))
* introduce task difficulties ([#64](https://github.com/dgokcin/dotfiles/issues/64)) ([bd61252](https://github.com/dgokcin/dotfiles/commit/bd61252022787f34aa89650905f4f4f7f484c279))
* update .cursorrules ([#61](https://github.com/dgokcin/dotfiles/issues/61)) ([daa6011](https://github.com/dgokcin/dotfiles/commit/daa601178bbea716219405355847070b579ed82a))

## [1.11.0](https://github.com/dgokcin/dotfiles/compare/v1.10.0...v1.11.0) (2024-07-13)


### Features

* add create_pr function ([#58](https://github.com/dgokcin/dotfiles/issues/58)) ([f4beab3](https://github.com/dgokcin/dotfiles/commit/f4beab3e737e6781b07d4b5193d5330efd9818d7))
* disable vi-mode if running inside neovim ([#59](https://github.com/dgokcin/dotfiles/issues/59)) ([9931dd1](https://github.com/dgokcin/dotfiles/commit/9931dd163c7dac512fb49345332a756423d42638))


### Bug Fixes

* remove redundant rules from cursor ([#55](https://github.com/dgokcin/dotfiles/issues/55)) ([80c3406](https://github.com/dgokcin/dotfiles/commit/80c34069a0bc9278d9a2aeae687f4c199f11e9f0))
* update nvim path, correct symlinks ([#57](https://github.com/dgokcin/dotfiles/issues/57)) ([8caeb4a](https://github.com/dgokcin/dotfiles/commit/8caeb4a1f6dac77af0b28c7e14db7943ef403d01))

## [1.10.0](https://github.com/dgokcin/dotfiles/compare/v1.9.0...v1.10.0) (2024-06-15)


### Features

* introduce personas to the assistant ([#52](https://github.com/dgokcin/dotfiles/issues/52)) ([ef5af62](https://github.com/dgokcin/dotfiles/commit/ef5af62ddbfa12258e0308bc0e6293463b626b9b))

## [1.9.0](https://github.com/dgokcin/dotfiles/compare/v1.8.1...v1.9.0) (2024-05-09)


### Features

* add vscode plugin to nvim config ([#46](https://github.com/dgokcin/dotfiles/issues/46)) ([5cbd93e](https://github.com/dgokcin/dotfiles/commit/5cbd93e9d19ef1f6f47bb3419c58e3f63396f591))

## [1.8.1](https://github.com/dgokcin/dotfiles/compare/v1.8.0...v1.8.1) (2024-04-18)


### Bug Fixes

* get rid of linter errors in lsp.lua ([#42](https://github.com/dgokcin/dotfiles/issues/42)) ([4dbda2c](https://github.com/dgokcin/dotfiles/commit/4dbda2ca1e72effda205fb56cd18db28d7fa6764))

## [1.8.0](https://github.com/dgokcin/dotfiles/compare/v1.7.1...v1.8.0) (2024-03-05)


### Features

* customizing fast-cursor-move.nvim ([#34](https://github.com/dgokcin/dotfiles/issues/34)) ([cee9499](https://github.com/dgokcin/dotfiles/commit/cee9499a72ede773dff3d5fa48054a71b4952296))

## [1.7.1](https://github.com/dgokcin/dotfiles/compare/v1.7.0...v1.7.1) (2024-03-05)


### Bug Fixes

* override vscode-neovim keybindings for j and k ([#32](https://github.com/dgokcin/dotfiles/issues/32)) ([b6526eb](https://github.com/dgokcin/dotfiles/commit/b6526eb919b49136f5d4d8537591cc3ab81c51c0))

## [1.7.0](https://github.com/dgokcin/dotfiles/compare/v1.6.0...v1.7.0) (2024-02-29)


### Features

* add keymaps for C to change without yanking ([#28](https://github.com/dgokcin/dotfiles/issues/28)) ([9cfc77f](https://github.com/dgokcin/dotfiles/commit/9cfc77f1be0b9347f8b96c29aad8eee45cf8ca69))


### Bug Fixes

* rename gitconfig files ([#31](https://github.com/dgokcin/dotfiles/issues/31)) ([129ec2f](https://github.com/dgokcin/dotfiles/commit/129ec2fc21516f6df557ca39ed796314c177adab))

## [1.6.0](https://github.com/dgokcin/dotfiles/compare/v1.5.0...v1.6.0) (2024-02-13)


### Features

* add lazygit config file and makefile target ([a1bacff](https://github.com/dgokcin/dotfiles/commit/a1bacffa5e91af79c81f7167da71a4781cae0e18))


### Bug Fixes

* delete without yanking using register a ([76b4952](https://github.com/dgokcin/dotfiles/commit/76b495244e403ca0d9f695aca4d2e15760ed1a5a))
* make vim-visual-multi work with vscode ([05fe3af](https://github.com/dgokcin/dotfiles/commit/05fe3af1c72ad9cc91d4acd974519f5a8f1a9a63))
* resolve permission issue with wakatime plugin ([4a8f4b0](https://github.com/dgokcin/dotfiles/commit/4a8f4b0cf1df8786c0509453e17076da5855e4ff))

## [1.5.0](https://github.com/dgokcin/dotfiles/compare/v1.4.0...v1.5.0) (2024-02-07)


### Features

* enhance telescope-undo and toggleterm ([335e18b](https://github.com/dgokcin/dotfiles/commit/335e18b461153a164f9be4f11ce80cdac5e88c7c))
* **git:** make default branch vim on new repos ([269df44](https://github.com/dgokcin/dotfiles/commit/269df449076453197d251935209d56d9aa831da5))
* **nvim:** add copilot plugin ([720fc11](https://github.com/dgokcin/dotfiles/commit/720fc11de3d2f03d3892ad2319d100a3a2faccf4))
* **nvim:** add keymap for exiting terminal mode ([d6b0fdd](https://github.com/dgokcin/dotfiles/commit/d6b0fdd05e9bd70b16c4fe2eae38e0df0e9c3ff1))
* **nvim:** add telescope-undo plugin ([354b330](https://github.com/dgokcin/dotfiles/commit/354b33082344fe137b0709073ecd251793a11846))
* **nvim:** add toggleterm and term-edit plugins ([7a24d72](https://github.com/dgokcin/dotfiles/commit/7a24d72dc70789857334d36910b76bdc208c33d1))
* **nvim:** remove s keymap from flash.nvim ([506a6a1](https://github.com/dgokcin/dotfiles/commit/506a6a1d0b0c5753f464318df9eecd02e40537fa))
* **zsh:** fix boot time problem for zsh ([199e487](https://github.com/dgokcin/dotfiles/commit/199e48782dd99015880e8b9e45688fec7e271b61))


### Bug Fixes

* enable lazy loading for toggleterm&term-edit ([2917075](https://github.com/dgokcin/dotfiles/commit/2917075f529c3fdca069c00b9ccacb1d1fa50cd6))
* **nvim-tree:** change open vertical split keymap ([6ba9fda](https://github.com/dgokcin/dotfiles/commit/6ba9fda13e0b852437aa15a1bec320e87701ea67))
* **telescope-undo:** fix preview height ([d696226](https://github.com/dgokcin/dotfiles/commit/d6962266598b61d619db7dc8a5061110e9c687b6))

## [1.4.0](https://github.com/dgokcin/dotfiles/compare/v1.3.0...v1.4.0) (2024-01-17)


### Features

* enable tab completion in nvim-cmp ([a5a58bb](https://github.com/dgokcin/dotfiles/commit/a5a58bb2630d41d0548f699023357617b99a9c91))
* **nvim:** add vscode support for some plugins ([e6eeb8d](https://github.com/dgokcin/dotfiles/commit/e6eeb8de04d1c7d86ca4826dbc41f5915ff336c6))
* **nvim:** add vscode-multi-cursor plugin ([e4eaa24](https://github.com/dgokcin/dotfiles/commit/e4eaa24ea04cf0b436ac959525b887c2cc1e9e51))
* **nvim:** disable swap files ([041c430](https://github.com/dgokcin/dotfiles/commit/041c43087fffd36358b1cfad449b916ff179849c))
* **nvim:** enhance git short-log alias ([c022470](https://github.com/dgokcin/dotfiles/commit/c022470513a2542714e6aa6bb5065fa71add1215))
* **nvim:** migrate to lazyvim ([e40ad40](https://github.com/dgokcin/dotfiles/commit/e40ad402937c7638aa118ae9caa79a33c3e58918))


### Bug Fixes

* **checker:** disable notifications ([94b6914](https://github.com/dgokcin/dotfiles/commit/94b691477c4f38583116b15737c217ef90380f3b))
* disable mini.ai plugin ([22705b9](https://github.com/dgokcin/dotfiles/commit/22705b9b9f4095b8eeec5df60b5ec628286f682d))
* disable vim-illuminate ([1dccb04](https://github.com/dgokcin/dotfiles/commit/1dccb043fc2ee66e4affaed400f5e61fd5ddfac1))
* **nvim:** properly disable neo-tree plugin ([1486a80](https://github.com/dgokcin/dotfiles/commit/1486a8056779c03add912d5030d12af0f6f5a7c5))
* show shrug in dashboard ([ff9d417](https://github.com/dgokcin/dotfiles/commit/ff9d4173e70a52470232c050675c0474efc3b58b))

## [1.3.0](https://github.com/dgokcin/dotfiles/compare/v1.2.0...v1.3.0) (2024-01-15)


### Features

* add bufferline plugin ([fb49050](https://github.com/dgokcin/dotfiles/commit/fb49050f2aa91351573f3c8dd7a970465c84c543))
* **nvim:** add alpha-nvim plugin ([d39aeb7](https://github.com/dgokcin/dotfiles/commit/d39aeb7fe77e9e274ff5080cbd33ec3c0829d46f))
* **nvim:** add noice.nvim for floating terminal ([0d21654](https://github.com/dgokcin/dotfiles/commit/0d216546bf795f46f5d504a525eee819064bac27))
* **nvim:** add persistence.nvim plugin ([e97ecb5](https://github.com/dgokcin/dotfiles/commit/e97ecb58efbbc1eb8b749daa4cf7d2c35fc681f6))
* **nvim:** add telescope git commands ([d508efc](https://github.com/dgokcin/dotfiles/commit/d508efcab44379232a7fb14458e8474d5c1d0162))
* **nvim:** add terraform and hcl to treesitter ([b3cd6e4](https://github.com/dgokcin/dotfiles/commit/b3cd6e40fe014437b1d7f3a17c33381ca7744d80))
* **nvim:** change theme to tokyonight ([5f7785c](https://github.com/dgokcin/dotfiles/commit/5f7785cfe62ce36b2dc3daf53182f9c19fad203a))


### Bug Fixes

* add BufRead to plugins for faster startup ([1054d7f](https://github.com/dgokcin/dotfiles/commit/1054d7fe1551811484ab1927c7a6b9f4eff6bcc7))
* remove unnecessary files ([e0c8eff](https://github.com/dgokcin/dotfiles/commit/e0c8eff7183421057a2913796bfb19a498068eff))
* standardize telescope keymap descriptions ([bc64874](https://github.com/dgokcin/dotfiles/commit/bc6487456dfbd81649b8441573fae13358f92d37))

## [1.2.0](https://github.com/dgokcin/dotfiles/compare/v1.1.0...v1.2.0) (2024-01-10)


### Features

* add git commit verbose ([02b3606](https://github.com/dgokcin/dotfiles/commit/02b360620b069046ee57ffb9d349c5347d04e8c0))
* add substitute plugin ([e0561bb](https://github.com/dgokcin/dotfiles/commit/e0561bba2e2b68df1c08ada2a2a1deb7bdc8b3fc))
* **nvim:** add autopairs plugin ([ee2bc04](https://github.com/dgokcin/dotfiles/commit/ee2bc04072a9df434a22138e9282ab9872d78f5d))


### Bug Fixes

* remove desc from keymap ([ada8d77](https://github.com/dgokcin/dotfiles/commit/ada8d776cc8940e132c8a85b6d433f9ad3c3f2c9))

## [1.1.0](https://github.com/dgokcin/dotfiles/compare/v1.0.0...v1.1.0) (2024-01-08)


### Features

* add command abbreviations ([6667c65](https://github.com/dgokcin/dotfiles/commit/6667c65a54e7cf07d85da0b5f1cc079bade1b00f))
* add nvim config ([a49dd34](https://github.com/dgokcin/dotfiles/commit/a49dd3476839a45e499aa1db3e3c9f10de4cea55))
* replace nvim-comment with comment.nvim ([5df0fa3](https://github.com/dgokcin/dotfiles/commit/5df0fa3bbab30a1273690809aba4d807af5e9b38))

## 1.0.0 (2024-01-08)


### Features

* add updated settings ([0504f0e](https://github.com/dgokcin/dotfiles/commit/0504f0e02b53d16570b99ee5b9cf4029499c534c))
* **ci:** add release-please integration ([f5ed714](https://github.com/dgokcin/dotfiles/commit/f5ed714f97fb3a492be75864656f8d4ee099e55f))
