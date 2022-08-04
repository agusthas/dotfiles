#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

apt_packages="zsh zip unzip curl wget stow jq tmux git httpie"

brew_packages="git httpie tmux jq"

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

    # if [[ ! -f "/etc/apt/sources.list.d/charm.list" ]]; then
    #   echo "Installing Charm PPA..."
    #   sudo echo 'deb [trusted=yes] https://repo.charm.sh/apt/ /' > /etc/apt/sources.list.d/charm.list
    # fi

    if [[ ! -f "/etc/apt/sources.list.d/httpie.list" ]]; then
      echo "Installing Httpie PPA..."
      curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo apt-key add -
      sudo curl -SsL -o /etc/apt/sources.list.d/httpie.list https://packages.httpie.io/deb/httpie.list
    fi

    # Update and upgrade packages
    sudo apt-get update && sudo apt-get upgrade -y

    # Installing base dependencies
    echo "Installing dependencies..."
    sudo apt-get install -y ${apt_packages}

      if ! echo "$SHELL" | grep -q "zsh"; then
        echo "Please manually change shell to zsh."
        echo "You can do this by running:"
        echo "  chsh -s \$(which zsh)"
      fi
    ;;
  'Darwin')
    echo "======= MAC ======="
    brew install ${brew_packages}
    ;;
  *)
    echo "Unsupported OS"
    exit 1
    ;;
esac

FZF_DIR="$HOME/.fzf"
if [[ ! -d "$FZF_DIR" ]]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR"
else
  git -C "$FZF_DIR" pull --rebase --force
fi
"$FZF_DIR/install" --bin

clear
export PATH="$PATH:$HOME/.fzf"
/usr/bin/env bash -c "$SCRIPT_DIR/dotfiles.sh"
/usr/bin/env bash -c "$SCRIPT_DIR/app.sh"

echo "[install.sh] Done!"

