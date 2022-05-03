#!/usr/bin/env bash

set -o pipefail
printf "\n"

# shellcheck disable=SC1091
source "$(dirname "$(readlink -f "$0")")/shared/functions.sh"

stow_dotfiles() {
  stow -d "$HOME/dotfiles" -t ~ "$1"
}

info "Linking dotfiles to home directory..."
stow zsh
stow p10k
stow git
stow nvim
stow binaries

printf "\n"
info "If there's an error with stow, it might be a conflict between the files"
info "  in your home directory and the dotfiles."
info "  use the ${YELLOW}diff${NO_COLOR} command to see what's different."
info "Once you're done, delete the files in your home directory"
info "  and run ${BOLD}\`dotfiles.sh\`${NO_COLOR} script again."