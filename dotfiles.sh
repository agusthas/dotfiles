#!/usr/bin/env bash

printf "\n"

stow_dotfiles() {
  stow -d "$HOME/dotfiles" -t ~ --verbose=2 "$@"
}

# Create initial bin directories
# This is a workaround for the fact that stow SYMLINK the directory if it doesn't exist
if [ ! -d "$HOME/bin" ]; then
  mkdir -p "$HOME/bin"
fi

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
