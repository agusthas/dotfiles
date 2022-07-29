#!/usr/bin/env bash

set -o pipefail
printf "\n"

stow_dotfiles() {
  stow -d "$HOME/dotfiles" -t ~ "$1"
}

echo "Linking dotfiles to home directory..."
stow_dotfiles zsh
stow_dotfiles p10k
stow_dotfiles git
stow_dotfiles nvim