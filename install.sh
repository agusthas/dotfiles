#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

shared_packages=(
  "zsh"
  "jq"
  "tmux"
  "git"
  "httpie"
  "neovim"
  "stow"
)

apt_packages=(
  "${shared_packages[@]}"
  "zip"
  "unzip"
  "curl"
)

brew_packages=(
  "fzf"
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

  if ! grep -q ".*git-core/ppa.*" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
    echo "Installing Git PPA..."
    sudo add-apt-repository ppa:git-core/ppa
  fi

  if ! grep -q ".*neovim-ppa/stable.*" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
    echo "Installing Neovim PPA..."
    sudo add-apt-repository ppa:neovim-ppa/stable
  fi

  if [[ ! -f "/etc/apt/sources.list.d/httpie.list" ]]; then
    echo "Installing Httpie PPA..."
    curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/httpie.gpg
    echo "deb [signed-by=/etc/apt/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" | sudo tee /etc/apt/sources.list.d/httpie.list >/dev/null
  fi

  # Update and upgrade packages
  sudo apt-get update && sudo apt-get upgrade -y

  # Installing base dependencies
  echo "Installing dependencies..."
  sudo apt-get install -y "${apt_packages[@]}"

  FZF_DIR="$HOME/.fzf"
  if [[ ! -d "$FZF_DIR" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR"
  else
    git -C "$FZF_DIR" pull --rebase --force
  fi
  "$FZF_DIR/install" --bin
  export PATH="$PATH:$HOME/.fzf/bin"

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

/usr/bin/env bash -c "$SCRIPT_DIR/dotfiles.sh"
/usr/bin/env bash -c "$SCRIPT_DIR/app.sh"

echo "[install.sh] Done!"
