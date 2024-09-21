#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
OS=$(uname -s)

[ OS = "Linux" ] && echo "LINUX NOT SUPPORTED YET" && exit 1

# Parse Flags
parse_args() {
  while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
      --skip-base)
        skip_base="true"
        shift # past argument
        ;;
      --skip-symlinks)
        skip_symlinks="true"
        shift # past argument
        ;;
      --skip-extras)
        skip_extras="true"
        shift # past argument
        ;;
      --symlinks)
        skip_base="true"
        skip_extras="true"
        shift # past argument
        ;;
    esac
  done
}

base_install() {
  local shared_packages=(
    "zsh"
    "tmux"
    "git"
    "stow"
    "fzf"
  )

  local apt_packages=(
    "${shared_packages[@]}"
    "curl"
    "zip"
    "unzip"
    "p7zip-full"
    "p7zip-rar"
    "fd-find"
    "bat"
    "gojq"
  )

  local brew_packages=(
    "${shared_packages[@]}"
    "fnm"
    "bfs"
    "starship"
  )

  # Generate ASCII Text
  if ! type base64 gunzip >/dev/null; then
    echo "= INSTALL.SH ="
  else
    base64 -d <<<"H4sIAKGGEWMAA51NwRHAMAj6OwXP9uVCuWMRhy+YmAHqeUgECQCqQM9DOQPo7UWM2R1A6p2JSggp2inmKKvSDzZpyR06GyG5sMZnj07FNTc60g6HCkI7f5RlFHXCgWJ5tQXmw3fMbQn8rg8Stz4QJgEAAA==" | gunzip
  fi
  printf "\n"

  case "$(uname -s)" in
  'Linux')
    echo "======= LINUX ======="
    echo "Escalated permission are required to install base packages"
    if ! sudo -v; then
      exit 1
    fi
    printf "\n"

    echo "PRE COMMANDS"
    # git
    sudo add-apt-repository --no-update -y ppa:git-core/ppa

    # Installing base dependencies
    echo && echo "Installing dependencies..."
    sudo apt-get update && sudo apt-get upgrade -y # Update and upgrade packages
    sudo apt-get install -y "${apt_packages[@]}"

    # post-commands for several packages
    echo && echo "POST COMMANDS"
    mkdir -p ~/bin

    if ! echo "$SHELL" | grep -q "zsh"; then
      echo "Please manually change shell to zsh."
      echo "You can do this by running:"
      echo "  chsh -s \$(which zsh)"
      exit 1
    else
      # bat
      echo "[INFO] Creating batcat alias..."
      ln -s $(which batcat) ~/bin/bat

      # fd
      echo "[INFO] Creating fdfind alias..."
      ln -s $(which fdfind) ~/bin/fd
      
      # fnm
      if ! type fnm >/dev/null; then
        echo "[INFO] Installing fnm..."
        curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$HOME/bin" --skip-shell
      fi
    fi
    ;;
  'Darwin')
    echo "======= MAC ======="
    brew install "${brew_packages[@]}"
    ;;
  *)
    echo "Unsupported OS"
    exit 1
    ;;
  esac
}

git_pull_or_clone() {
  local repo="$1"
  local dir="$2"

  if [[ -d "$dir" ]]; then
    echo "[INFO] Pulling $repo..."
    git -C "$dir" pull --rebase --force
  else
    echo "[INFO] Cloning $repo..."
    git clone --depth=1 "$repo" "$dir"
  fi
}

create_symlinks() {
  echo "Creating symlinks"

  # Stow --no-folding means that it will not create parent directories
  local cmd="stow -d $SCRIPT_DIR -t $HOME --no-folding --verbose=1"

  mkdir -p "$HOME/bin" "$HOME/.config"

  $cmd \
    zsh \
    git \
    tmux \
    vim \
    starship
  
  if [ "$OS" = "Linux" ]; then
    $cmd ubuntu 
  elif [ "$OS" = "Darwin" ]; then
    $cmd macos
  fi
}

parse_args "$@"
[ "$skip_base" != "true" ] && base_install
[ "$skip_symlinks" != "true" ] && create_symlinks
# if [ "$skip_extras" != "true" ]; then
#   setup_ohmyzsh
#   setup_fzfgit
# fi

echo "[install.sh] Done!"
