#!/usr/bin/env bash

printf "\n"

stow_dotfiles() {
  stow -d "$HOME/dotfiles" -t ~ --verbose=2 "$@"
}

stow_dotfiles zsh p10k git nvim tmux bin

case "$(uname -s)" in
  'Linux')
    # stow_dotfiles ssh
    ;;
  'Darwin')
    ;;
  *)
    echo "Unsupported OS"
    exit 1
    ;;
esac
