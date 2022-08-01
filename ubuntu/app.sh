#!/usr/bin/env bash

set -o pipefail
printf "\n"

# Functions to install packages from github
# Usage:
#  install_from_github <command-name> <repo-short-url>
#
# Example:
#  install_from_github fd sharkdp/fd force
install_from_github() {
  local is_force="$3"
  local is_command_exists="$(command -v "$1" 2>/dev/null)"

  if [[ ! -n "$is_command_exists" ]] || [[ -n "$is_force" ]]; then
    local tmp="/tmp/.github-install"
    local binpath="$HOME/bin"

    rm -rf $tmp
    mkdir -p $tmp
    local url="https://api.github.com/repos/$2/releases/latest"
    echo "Reading... $url"

    PS3="Select download file: "
    select filename in $(curl -s "$url" | jq -r '.assets[].name'); do break; done
    echo "Downloading... $filename"
    curl -s "$url" \
      | jq -r --arg filename "$filename" '.assets[] | select(.name == $filename) | .browser_download_url' \
      | wget -i- -q --show-progress -P "$tmp"

    pushd $tmp

    if [ -f "$filename" ]; then
      case $filename in
        *.tar.bz2)  tar xjf $filename      ;;
        *.tar.gz)   tar xzf $filename      ;;
        *.tar.xz)   tar xzf $filename      ;;
        *.bz2)      bunzip2 $filename      ;;
        *.gz)       gunzip $filename       ;;
        *.tar)      tar xf $filename       ;;
        *.tbz2)     tar xjf $filename      ;;
        *.tgz)      tar xzf $filename      ;;
        *.zip)      unzip $filename        ;;
        *.Z)        uncompress $filename   ;;
        *.rar)      rar x $filename        ;;  # 'rar' must to be installed
        *.jar)      jar -xvf $filename     ;;  # 'jdk' must to be installed
        *)          echo "'$filename' cannot be extracted via extract()" ;;
      esac
    else
      echo "'$filename' is not a valid file"
      exit 1
    fi

    PS3="Select binary: "
    select bin in $(find . -type f); do break; done
    popd

    # install
    basename=$(basename $bin)
    read -p "Choose an alias (empty to leave: $basename): " alias
    target="$binpath/${alias:-$basename}"
    mv "$tmp/$bin" "$target"
    chmod +x "$target"
    echo "Success!"
    echo "Saved in: $target"
  else
    echo "Command '$1' already exists."
  fi
}

echo "ohmyzsh"
OMZ_DIR="$HOME/.oh-my-zsh"
if [ -d "$OMZ_DIR" ]; then
  /bin/zsh -i -c 'omz update'
else
  echo "Installing oh-my-zsh"
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
fi

omz_custom_dir="${ZSH_CUSTOM:-$OMZ_DIR/custom}"
## p10k
P10K_DIR="$omz_custom_dir/themes/powerlevel10k"
echo "p10k"
if [ -d "$P10K_DIR" ]; then
  git -C "$P10K_DIR" pull --rebase --force
else
  echo "Installing p10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

## zsh-autosuggestions
ZSH_AUTOSUGGESTIONS_DIR="$omz_custom_dir/plugins/zsh-autosuggestions"
echo "zsh-autosuggestions"
if [ -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
  git -C "$ZSH_AUTOSUGGESTIONS_DIR" pull --rebase --force
else
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
fi

## zsh-syntax-highlighting
ZSH_SYNTAX_HIGHLIGHTING_DIR="$omz_custom_dir/plugins/zsh-syntax-highlighting"
echo "zsh-syntax-highlighting"
if [ -d "$ZSH_SYNTAX_HIGHLIGHTING_DIR" ]; then
  git -C "$ZSH_SYNTAX_HIGHLIGHTING_DIR" pull --rebase --force
else
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_HIGHLIGHTING_DIR"
fi

## fzf
FZF_DIR="$HOME/.fzf"
echo "fzf"
if [ -d "$FZF_DIR" ]; then
  git -C "$FZF_DIR" pull --rebase --force
else
  git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR"
fi
"$FZF_DIR/install" --bin

# START FROM HERE (PLATFORM SPECIFIC)
OS="$(uname -s)"
case "$OS" in
  'Linux')
    install_from_github fd sharkdp/fd
    install_from_github fnm Schniz/fnm
    install_from_github nvim neovim/neovim
    install_from_github exa ogham/exa
    install_from_github bat sharkdp/bat
    ;;
  'Darwin')
    brew install bat fd fnm neovim exa
    ;;
  *)
    echo "Unsupported OS"
    exit 1
    ;;
esac

echo "Done!"