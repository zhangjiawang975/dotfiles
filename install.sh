#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }
err()  { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2; }

# 1. Check prerequisites
for cmd in git zsh; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    err "Missing required command: $cmd. Please install it first (e.g., sudo apt install -y $cmd)."
    exit 1
  fi
done

# 2. Install Oh My Zsh (shallow clone, lightweight & no curl required)
if [ -d "$ZSH_DIR" ]; then
  info "Oh My Zsh already exists at $ZSH_DIR, skipping installation."
else
  info "Installing Oh My Zsh to $ZSH_DIR..."
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR"
fi

# 3. Install custom plugins
install_plugin() {
  local name="$1"
  local repo="$2"
  local target="$ZSH_CUSTOM/plugins/$name"

  if [ -d "$target" ]; then
    info "Plugin '$name' already exists, skipping."
  else
    info "Installing plugin '$name'..."
    git clone --depth=1 "$repo" "$target"
  fi
}

install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"

# 4. Link .zshrc (backup existing file if needed)
TARGET_ZSHRC="$HOME/.zshrc"
SOURCE_ZSHRC="$DOTFILES_DIR/.zshrc"

if [ -L "$TARGET_ZSHRC" ] && [ "$(readlink -f "$TARGET_ZSHRC")" = "$(readlink -f "$SOURCE_ZSHRC")" ]; then
  info "$TARGET_ZSHRC is already linked to $SOURCE_ZSHRC."
else
  if [ -e "$TARGET_ZSHRC" ] || [ -L "$TARGET_ZSHRC" ]; then
    BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
    warn "Backing up existing $TARGET_ZSHRC to $BACKUP"
    mv "$TARGET_ZSHRC" "$BACKUP"
  fi
  ln -s "$SOURCE_ZSHRC" "$TARGET_ZSHRC"
  info "Linked $TARGET_ZSHRC -> $SOURCE_ZSHRC"
fi

# 5. Configure Antigravity CLI (agy) statusLine, title & notifications
if [ -x "$DOTFILES_DIR/agy/install.sh" ] || [ -f "$DOTFILES_DIR/agy/install.sh" ]; then
  if command -v python3 >/dev/null 2>&1; then
    bash "$DOTFILES_DIR/agy/install.sh"
  else
    warn "python3 not found, skipping agy configuration."
  fi
fi

# 6. Summary & next steps
info "Done!"
echo ""
echo "Next steps:"
if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
  echo "  1. Set zsh as default shell:  chsh -s \"\$(which zsh)\""
fi
echo "  - Start zsh now:              exec zsh"
echo "  - Put private/local config in: ~/.zshrc.local (not tracked by git)"
echo "  - Note: 'agnoster' theme looks best with a Powerline / Nerd Font in your terminal."
