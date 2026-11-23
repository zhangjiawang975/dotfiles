# dotfiles

轻量级 Oh My Zsh 配置，方便在新的 Linux / WSL 环境中快速复用。

## 包含内容

- **主题**：`agnoster`（含目录配色微调 `AGNOSTER_DIR_BG=060` 及 `LS_COLORS` 目录柔和蓝色）
- **内置插件**：`git`、`z`、`extract`、`docker`、`docker-compose`
- **第三方插件**（安装脚本自动拉取）：
  - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
  - [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- **Antigravity CLI (`agy`) 增强配置**（`agy/`）：
  - `agy/statusline.sh`：自定义底部状态栏（显示模型、上下文用量、配额剩余与重置倒计时、Git 分支等）
  - `agy/title.sh`：终端标签页动态标题（显示思考中/执行中/等待确认/已完成状态 + 当前工作区名）
  - `agy/install.sh`：无损合并配置到 `~/.gemini/antigravity-cli/settings.json`（开启 `notifications` 响铃通知、`statusLine` 与 `title`，不覆盖原有权限和工作区设置）

## 快速安装

在新 Linux 机器上确保已安装 `zsh` 和 `git`，然后执行：

```bash
git clone https://github.com/zhangjiawang975/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

如果只需要单独更新/安装 `agy` 的状态栏与标题配置，也可以直接执行：

```bash
~/dotfiles/agy/install.sh
```

安装脚本会自动完成：
1. 浅克隆安装 Oh My Zsh（`~/.oh-my-zsh`）
2. 安装第三方插件（`zsh-autosuggestions`、`zsh-syntax-highlighting`）
3. 备份已有的 `~/.zshrc` 并软链接本仓库的 `.zshrc`
4. 配置 `agy` 状态栏、动态标题及通知提醒（`~/.gemini/antigravity-cli/settings.json`）

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
