#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
OS=$(uname -s)

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
    "jq"
    "tmux"
    "git"
    "stow"
    "fzf"
    "bat"
  )

  local apt_packages=(
    "${shared_packages[@]}"
    "zip"
    "unzip"
    "p7zip-full"
    "p7zip-rar"
    "fd-find"
  )

  local brew_packages=(
    "${shared_packages[@]}"
    "fd"
    "fnm"
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

    if ! echo "$SHELL" | grep -q "zsh"; then
      echo "Please manually change shell to zsh."
      echo "You can do this by running:"
      echo "  chsh -s \$(which zsh)"
      exit 1
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

setup_ohmyzsh() {
  echo "Setting up ohmyzsh"

  echo "[INFO]" "oh-my-zsh"
  omz_install_dir="$HOME/.oh-my-zsh"

  if [ ! -d "$omz_install_dir" ]; then
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$omz_install_dir"
  else
    echo "[INFO]" "updating oh-my-zsh"
    zsh -ic 'omz update' 2>&1 >/dev/null
  fi

  echo "Installing zsh plugins and themes..."
  omz_custom_dir="$omz_install_dir/custom"

  echo "[INFO]" "p10k"
  p10k_install_dir="$omz_custom_dir/themes/powerlevel10k"
  git_pull_or_clone \
    https://github.com/romkatv/powerlevel10k.git \
    "$p10k_install_dir"

  echo "[INFO]" "zsh-autosuggestions"
  zsh_autosuggest_install_dir="$omz_custom_dir/plugins/zsh-autosuggestions"
  git_pull_or_clone \
    https://github.com/zsh-users/zsh-autosuggestions \
    "$zsh_autosuggest_install_dir"

  echo "[INFO]" "zsh-syntax-highlighting"
  zsh_syntax_install_dir="$omz_custom_dir/plugins/zsh-syntax-highlighting"
  git_pull_or_clone \
    https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$zsh_syntax_install_dir"
}

setup_ohmytmux() {
  echo "Setting up oh-my-tmux"

  echo "[INFO]" "oh-my-tmux"
  omt_install_dir="$HOME/.oh-my-tmux"
  git_pull_or_clone \
    https://github.com/gpakosz/.tmux \
    "$omt_install_dir" \
    && ln -s -f "$omt_install_dir/.tmux.conf" "$HOME/.tmux.conf"
}

create_symlinks() {
  echo "Creating symlinks"

  local cmd="stow -d $SCRIPT_DIR -t $HOME --verbose=1"

  mkdir -p "$HOME/bin" "$HOME/.config"

  $cmd \
    zsh \
    git \
    tmux \
    bin
  
  if [ "$OS" = "Linux" ]; then
    $cmd ubuntu 
  elif [ "$OS" = "Darwin" ]; then
    $cmd macos
  fi
}

parse_args "$@"
[ "$skip_base" != "true" ] && base_install
[ "$skip_symlinks" != "true" ] && create_symlinks
if [ "$skip_extras" != "true" ]; then
  setup_ohmyzsh
  setup_ohmytmux
fi

echo "[install.sh] Done!"
