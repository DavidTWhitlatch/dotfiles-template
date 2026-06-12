#!/usr/bin/env bash
#
# Bootstrap this dotfiles repo on a fresh macOS machine.
#
#   git clone https://github.com/DavidTWhitlatch/dotfiles-template.git ~/dotfiles
#   ~/dotfiles/install.sh
#
# Idempotent: safe to re-run. Each step is skipped if already done.
# Installers are told NOT to edit your shell rc files, so the rcm-managed
# ~/.zshrc symlink is never clobbered.

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"

log()  { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

# 1. Homebrew ---------------------------------------------------------------
if ! have brew; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Put brew on PATH for this script (Apple Silicon vs Intel prefixes differ)
if   [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ];   then eval "$(/usr/local/bin/brew shellenv)"
fi

# 2. Homebrew packages ------------------------------------------------------
log "Installing Homebrew packages (Brewfile)"
brew bundle --file="$DOTFILES/Brewfile"

# 3. fzf key bindings + completion (writes ~/.fzf.zsh, sourced by zshrc) -----
if [ ! -f "$HOME/.fzf.zsh" ]; then
  log "Configuring fzf key bindings"
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

# 4. oh-my-zsh --------------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing oh-my-zsh"
  # KEEP_ZSHRC=yes: don't touch ~/.zshrc; RUNZSH=no: don't drop into a subshell
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 5. oh-my-zsh custom plugin: zsh-autosuggestions (in zshrc's plugins list) ---
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  log "Installing zsh-autosuggestions plugin"
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# 6. nvm (official installer; dotfiles expect ~/.nvm) -----------------------
if [ ! -d "$HOME/.nvm" ]; then
  log "Installing nvm"
  # PROFILE=/dev/null: don't let the installer append to our managed ~/.zshrc
  export PROFILE=/dev/null
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# 7. Make zsh the login shell ----------------------------------------------
ZSH_BIN="$(command -v zsh)"
if [ "$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')" != "$ZSH_BIN" ]; then
  log "Setting zsh as your login shell"
  grep -qx "$ZSH_BIN" /etc/shells || echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$ZSH_BIN" || echo "    (chsh failed — change your login shell to zsh manually)"
fi

# 8. Symlink the dotfiles with rcm -----------------------------------------
log "Linking dotfiles with rcup"
env RCRC="$DOTFILES/rcrc" rcup -v

log "Done — open a new terminal, or run: exec zsh"
