# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="agnoster"

# Use a softer blue for the directory segment in agnoster theme
AGNOSTER_DIR_BG=060

# Plugins
# Standard plugins: $ZSH/plugins/
# Custom plugins:   $ZSH_CUSTOM/plugins/
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  z
  extract
  docker
  docker-compose
)

source "$ZSH/oh-my-zsh.sh"

# Use a softer blue for directories
export LS_COLORS="${LS_COLORS}:di=38;5;75"

# User local binaries
export PATH="$HOME/.local/bin:$PATH"

# Load machine-specific or private settings (not tracked by git)
# Put API keys, conda init, default working directory, etc. in ~/.zshrc.local
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi
