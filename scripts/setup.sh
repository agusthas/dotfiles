#!/usr/bin/env bash
# shellcheck disable=SC1091

set -o pipefail
printf '\n'


source "$(dirname "$(readlink -f "$0")")/shared/functions.sh"

if ! gh auth status 2>/dev/null; then
  info "Login to GitHub using gh."
  info "This step is required to install applications."
  info "By default, this will only work if you have a GitHub account."

  # If error occurs, exit
  gh auth login || exit 1
fi

# shellcheck disable=SC1091
source "$(dirname "$(readlink -f "$0")")/applications.sh"
source "$(dirname "$(readlink -f "$0")")/dotfiles.sh"

