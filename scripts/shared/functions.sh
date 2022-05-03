#!/usr/bin/env bash

BOLD="$(tput bold 2>/dev/null || printf '')"
UNDERLINE="$(tput smul 2>/dev/null || printf '')"
GREY="$(tput setaf 0 2>/dev/null || printf '')"
RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
BLUE="$(tput setaf 4 2>/dev/null || printf '')"
MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"
CYAN="$(tput setaf 6 2>/dev/null || printf '')"
WHITE="$(tput setaf 7 2>/dev/null || printf '')"
NO_COLOR="$(tput sgr0 2>/dev/null || printf '')"

info() {
  printf '%s\n' "${BOLD}${GREY}>${NO_COLOR} $*"
}

warn() {
  printf '%s\n' "${YELLOW}! $*${NO_COLOR}"
}

error() {
  printf '%s\n' "${RED}x $*${NO_COLOR}" >&2
}

completed() {
  printf '%s\n' "${GREEN}✓${NO_COLOR} $*"
}

get_tmpdir() {
  dirname="$(mktemp -d)"
  printf "%s" "${dirname}"
}

has() {
  command -v "$1" 1>/dev/null 2>&1
}

# Function: create_or_use_dir
# Description:
#  Creates a directory if it doesn't exist, otherwise uses the existing one.
#  If the directory is not empty, the user is prompted to continue.
#  If the user chooses to continue, the directory is removed and recreated.
#  If the user chooses to cancel, the function exits.
# Usage:
#  create_or_use_dir <directory>
create_or_use_dir() {
  dir="$1"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
  elif [[ -n "$(ls -A "$dir")" ]]; then
    warn "Directory '$dir' is not empty."
    read -p "Continue? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
    rm -rf "$dir"
    mkdir -p "$dir"
  fi
}

# Function: ask
# Description:
#   Ask the user a question and return the 0 if yes, 1 if no.
# Usage: 
#   ask <question> [default: Y/N]
# Example:
#   if ask "Do you want to continue?" Y; then
#     echo "Continuing..."
#   else
#     echo "Aborting..."
#   fi
ask() {
  if [[ ${2:-} = 'Y' ]]; then
    prompt="${BOLD}[y/n] (default: y)${NO_COLOR}"
    default='Y'
  elif [[ ${2:-} = 'N' ]]; then
    prompt="${BOLD}[y/n] (default: n)${NO_COLOR}"
    default='N'
  else
    prompt="${BOLD}[y/n]${NO_COLOR}"
    default=''
  fi

  while true; do
    printf "%s " "${BOLD}${MAGENTA}?${NO_COLOR} $1 $prompt"

    read -r answer </dev/tty

    if [[ -z $answer ]]; then
      answer=$default
    fi

    case $answer in
      Y*|y*)
        return 0
        ;;
      N*|n*)
        return 1
        ;;
      *)
        error "Please answer yes or no."
        ;;
    esac
  done
}

# Function: unpack
# Description:
#   Unpacks an archive into the current directory.
#   If the archive is a in known format, it will be
#   unpacked with the corresponding command.
#   If the archive is not in a known format, it will
#   be left untouched.
# Usage: 
#   unpack <archive>
# Example:
#   unpack myarchive.tar.gz
#   unpack myarchive.zip
unpack() {
  archive="$1"

  case "$archive" in
    *.tar.gz|*.tgz)
      tar -xzf "$archive"
      rm "$archive" &>/dev/null
      ;;
    *.tar.xz)
      tar -xf "$archive"
      rm "$archive" &>/dev/null
      ;;
    *.zip)
      unzip -q "$archive"
      rm "$archive" &>/dev/null
      ;;
    *)
      warn "unpack: unknown archive format: $archive"
      ;;
  esac
}

# Function: gh_download
# Description:
#   Downloads a file from GitHub.
# Usage:
#   gh_download <repo> <asset_pattern>
# Example:
#   gh_download "jarun/nnn" "*nnn-static*.tar.gz"
#   gh_download "neovim/neovim" "*nvim*.appimage"
gh_download() {
  repo="$1"
  pattern="$2"

  info "downloading (with gh)...."
  gh release download --repo "$repo" --pattern "$pattern"
  DOWNLOADED=$(find . -type f -name "$pattern")
  if [ ! -f "$DOWNLOADED" ]; then
    error "Something might happen when downloading"
    error "Possible reason: 1. gh release download error; 2. find error; 3. is not a file"
    return 1
  fi

  unpack "$DOWNLOADED"
}

# Function: url_download
# Description:
#   Downloads a file from a URL.
# Usage:
#   url_download <url> <filename>
# Example:
#   url_download https://www.7-zip.org/a/7z2107-linux-x64.tar.xz 7z2107-linux-x64.tar.xz
url_download() {
  url="$1"
  name="$2"

  info "downloading (with curl)...."
  curl --progress-bar --fail -L "$url" -o "$name"
  DOWNLOADED=$(find . -type f -name "$name")
  if [ ! -f "$DOWNLOADED" ]; then
    error "Something might happen when downloading"
    error "Possible reason: 1. curl error; 2. find error; 3. is not a file"
    return 1
  fi

  unpack "$DOWNLOADED"
}