#!/usr/bin/env bash

YES="Yes"
NO="No"
APP_BIN_DIR=${APP_BIN_DIR:-$HOME/bin}

__log() {
  echo -e "$1"
}

__info() {
  echo -e "[INFO] $1"
}

__completed() {
  echo -e "[✓] $1"
}

__error() {
  echo -e "[ERROR] $1"
}

__warn() {
  echo -e "[WARN] $1"
}

# START FROM HERE (PLATFORM SPECIFIC)
if [[ -z "$skip_binaries" ]]; then
  __log "Skip installing binaries?"
  skip_binaries=$(echo -e "$YES\n$NO" | fzf --height 30 --reverse --no-info) || exit 1
  __info "$skip_binaries\n"
fi

if ! [[ "$skip_binaries" = "$YES" ]]; then
  case "$(uname -s)" in
  'Linux')
    downgit sharkdp/fd "$APP_BIN_DIR"
    downgit Schniz/fnm "$APP_BIN_DIR"
    downgit ogham/exa "$APP_BIN_DIR"
    downgit sharkdp/bat "$APP_BIN_DIR"
    downgit cli/cli "$APP_BIN_DIR"
    ;;
  'Darwin')
    brew install bat fd fnm neovim exa gh
    ;;
  *)
    __log "Unsupported OS"
    exit 1
    ;;
  esac
fi

# UNIVERSAL
__log "UNIVERSAL"

__completed "oh-my-zsh"
OMZ_DIR="$HOME/.oh-my-zsh"
if [[ ! -d "$OMZ_DIR" ]]; then
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
else
  echo "Already up to date."
fi

__completed "p10k"
omz_custom_dir="${ZSH_CUSTOM:-$OMZ_DIR/custom}"
P10K_DIR="$omz_custom_dir/themes/powerlevel10k"
if [ -d "$P10K_DIR" ]; then
  git -C "$P10K_DIR" pull --rebase --force
else
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

__completed "zsh-autosuggestions"
ZSH_AUTOSUGGESTIONS_DIR="$omz_custom_dir/plugins/zsh-autosuggestions"
if [ -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
  git -C "$ZSH_AUTOSUGGESTIONS_DIR" pull --rebase --force
else
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
fi

__completed "zsh-syntax-highlighting"
ZSH_SYNTAX_HIGHLIGHTING_DIR="$omz_custom_dir/plugins/zsh-syntax-highlighting"
if [ -d "$ZSH_SYNTAX_HIGHLIGHTING_DIR" ]; then
  git -C "$ZSH_SYNTAX_HIGHLIGHTING_DIR" pull --rebase --force
else
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_HIGHLIGHTING_DIR"
fi
