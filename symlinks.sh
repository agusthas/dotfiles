#!/usr/bin/env bash

echo "Creating symlinks..."

create_symlinks() {
  stow -d "$HOME/dotfiles" -t ~ --verbose=1 "$@"
}

# This is a workaround for the fact that stow SYMLINK the directory if it doesn't exist
mkdir -p "$HOME/bin" "$HOME/.config"

create_symlinks \
  zsh \
  git \
  tmux \
  bin

case "$(uname -s)" in
'Linux')
  create_symlinks ubuntu
  ;;
'Darwin')
  create_symlinks macos
  ;;
esac

echo "[symlinks.sh] Done!"
