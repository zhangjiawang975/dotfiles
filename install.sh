#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }
err()  { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2; }

usage() {
  cat <<'EOF'
Usage: ./install.sh [component...]

Components:
  all    Install all components (default when no arguments are given)
  zsh    Install Oh My Zsh, plugins, and link ~/.zshrc
  tmux   Link ~/.tmux.conf
  agy    Configure Antigravity CLI (agy) statusLine, title & notifications

Examples:
  ./install.sh              # Install everything
  ./install.sh tmux         # Install tmux config only
  ./install.sh zsh tmux     # Install zsh and tmux configs
  ./install.sh agy          # Install agy config only
EOF
}

link_file() {
  local source_file="$1"
  local target_file="$2"

  if [ -L "$target_file" ] && [ "$(readlink -f "$target_file")" = "$(readlink -f "$source_file")" ]; then
    info "$target_file is already linked to $source_file."
  else
    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
      local backup="${target_file}.backup.$(date +%Y%m%d%H%M%S)"
      warn "Backing up existing $target_file to $backup"
      mv "$target_file" "$backup"
    fi
    ln -s "$source_file" "$target_file"
    info "Linked $target_file -> $source_file"
  fi
}

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

install_zsh() {
  for cmd in git zsh; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      err "Missing required command for zsh setup: $cmd. Please install it first (e.g., sudo apt install -y $cmd)."
      exit 1
    fi
  done

  if [ -d "$ZSH_DIR" ]; then
    info "Oh My Zsh already exists at $ZSH_DIR, skipping installation."
  else
    info "Installing Oh My Zsh to $ZSH_DIR..."
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR"
  fi

  install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
  install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"

  link_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
}

install_tmux() {
  link_file "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

  if ! command -v tmux >/dev/null 2>&1; then
    warn "tmux not found; ~/.tmux.conf has been linked and will take effect once tmux is installed."
  fi
}

install_agy() {
  if [ -x "$DOTFILES_DIR/agy/install.sh" ] || [ -f "$DOTFILES_DIR/agy/install.sh" ]; then
    if command -v python3 >/dev/null 2>&1; then
      bash "$DOTFILES_DIR/agy/install.sh"
    else
      warn "python3 not found, skipping agy configuration."
    fi
  else
    warn "$DOTFILES_DIR/agy/install.sh not found, skipping agy configuration."
  fi
}

# Parse arguments
DO_ZSH=false
DO_TMUX=false
DO_AGY=false

if [ $# -eq 0 ]; then
  DO_ZSH=true
  DO_TMUX=true
  DO_AGY=true
else
  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        usage
        exit 0
        ;;
      all)
        DO_ZSH=true
        DO_TMUX=true
        DO_AGY=true
        ;;
      zsh)
        DO_ZSH=true
        ;;
      tmux)
        DO_TMUX=true
        ;;
      agy)
        DO_AGY=true
        ;;
      *)
        err "Unknown component: $arg"
        echo ""
        usage
        exit 1
        ;;
    esac
  done
fi

# Run selected components
if [ "$DO_ZSH" = true ]; then
  install_zsh
fi

if [ "$DO_TMUX" = true ]; then
  install_tmux
fi

if [ "$DO_AGY" = true ]; then
  install_agy
fi

# Summary & next steps
info "Done!"
if [ "$DO_ZSH" = true ]; then
  echo ""
  echo "Next steps (zsh):"
  if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
    echo "  1. Set zsh as default shell:  chsh -s \"\$(which zsh)\""
  fi
  echo "  - Start zsh now:              exec zsh"
  echo "  - Put private/local config in: ~/.zshrc.local (not tracked by git)"
  echo "  - Note: 'agnoster' theme looks best with a Powerline / Nerd Font in your terminal."
fi
if [ "$DO_TMUX" = true ]; then
  echo ""
  echo "Next steps (tmux):"
  echo "  - Reload inside tmux:         prefix + r  (or: tmux source-file ~/.tmux.conf)"
fi
