# dotfiles

轻量级 Oh My Zsh 配置，方便在新的 Linux / WSL 环境中快速复用。

## 包含内容

- **主题**：`agnoster`（含目录配色微调 `AGNOSTER_DIR_BG=060` 及 `LS_COLORS` 目录柔和蓝色）
- **内置插件**：`git`、`z`、`extract`、`docker`、`docker-compose`
- **第三方插件**（安装脚本自动拉取）：
  - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
  - [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

## 快速安装

在新 Linux 机器上确保已安装 `zsh` 和 `git`，然后执行：

```bash
git clone https://github.com/zhangjiawang975/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

安装脚本会自动完成：
1. 浅克隆安装 Oh My Zsh（`~/.oh-my-zsh`）
2. 安装第三方插件（`zsh-autosuggestions`、`zsh-syntax-highlighting`）
3. 备份已有的 `~/.zshrc` 并软链接本仓库的 `.zshrc`

安装完成后切换到 zsh：

```bash
chsh -s "$(which zsh)"
exec zsh
```

## 本机私有配置

密钥（API Key / Token）、`conda init`、特定机器的路径或别名请放在 `~/.zshrc.local` 中，`.zshrc` 会自动加载它且不会被提交到 Git。

## 更新配置

```bash
cd ~/dotfiles && git pull
source ~/.zshrc
```

> 提示：`agnoster` 主题需要终端使用支持 Powerline 符号的字体（如 Nerd Fonts）才能正常显示箭头图标。
