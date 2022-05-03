#!/usr/bin/env bash

set -o pipefail
printf "\n"

# shellcheck disable=SC1091
source "$(dirname "$(readlink -f "$0")")/shared/functions.sh"

stow_dotfiles() {
  stow -d "$HOME/dotfiles" -t ~ "$1"
}

info "Linking dotfiles to home directory..."
stow_dotfiles zsh
stow_dotfiles p10k
stow_dotfiles git
stow_dotfiles nvim
stow_dotfiles binaries

printf "\n"
info "If there's an error with stow, it might be a conflict between the files"
echo "    in your home directory and the dotfiles. Use the ${YELLOW}diff${NO_COLOR} command to see what's different."
info "Once you're done, delete the files in your home directory"
echo "    and run ${BOLD}\`dotfiles.sh\`${NO_COLOR} script again."