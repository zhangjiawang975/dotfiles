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
- **tmux 配置**（`.tmux.conf`）：
  - 开启鼠标支持、真彩色（TrueColor）、低 ESC 延迟与 50000 行历史滚动
  - 窗口/窗格编号从 1 开始并自动重排
  - 便捷快捷键：`prefix + |` / `prefix + -` 沿当前目录分屏、`Alt + 方向键` 切换窗格、`Ctrl + 方向键` 调整大小、`prefix + r` 重载配置
  - Nord 风格纯文本状态栏与窗格边框（不依赖 Nerd Font / 第三方插件）

## 快速安装

克隆仓库到本地：

```bash
git clone https://github.com/zhangjiawang975/dotfiles.git ~/dotfiles
```

### 一键安装全部

```bash
~/dotfiles/install.sh
```

### 按需单独安装

支持通过参数指定单个或多个模块（各模块依赖独立检查，例如仅装 `tmux` 不需要安装 `zsh`）：

```bash
~/dotfiles/install.sh zsh          # 仅安装 Oh My Zsh、插件与 .zshrc
~/dotfiles/install.sh tmux         # 仅链接 .tmux.conf
~/dotfiles/install.sh agy          # 仅配置 Antigravity CLI（也可直接运行 ~/dotfiles/agy/install.sh）
~/dotfiles/install.sh zsh tmux     # 自由组合多个模块
~/dotfiles/install.sh --help       # 查看所有可用参数
```

各模块具体操作：
- **`zsh`**：浅克隆安装 Oh My Zsh（`~/.oh-my-zsh`）、安装第三方插件、备份并软链接 `~/.zshrc`
- **`tmux`**：备份并软链接 `~/.tmux.conf`
- **`agy`**：配置 `agy` 状态栏、动态标题及通知提醒（`~/.gemini/antigravity-cli/settings.json`）

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
