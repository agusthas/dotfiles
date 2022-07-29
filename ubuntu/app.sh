#!/usr/bin/env bash

set -o pipefail
printf "\n"

## 
extract() {
  for arg in $@; do
    if [ -f "$arg" ]; then
      case $arg in
        *.tar.bz2)  tar xjf $arg      ;;
        *.tar.gz)   tar xzf $arg      ;;
        *.tar.xz)   tar xzf $arg      ;;
        *.bz2)      bunzip2 $arg      ;;
        *.gz)       gunzip $arg       ;;
        *.tar)      tar xf $arg       ;;
        *.tbz2)     tar xjf $arg      ;;
        *.tgz)      tar xzf $arg      ;;
        *.zip)      unzip $arg        ;;
        *.Z)        uncompress $arg   ;;
        *.rar)      rar x $arg        ;;  # 'rar' must to be installed
        *.jar)      jar -xvf $arg     ;;  # 'jdk' must to be installed
        *)          echo "'$arg' cannot be extracted via extract()" ;;
      esac
    else
      echo "'$arg' is not a valid file"
    fi
  done
}

install_from_github() {
  local tmp="/tmp/.github-install"
  local binpath="$HOME/bin"

  rm -rf $tmp
  mkdir -p $tmp
  local url="https://api.github.com/repos/$1/releases/latest"
  echo "Reading... $url"

  PS3="Select download file: "
  select filename in $(curl -s "$url" | jq -r '.assets[].name'); do break; done
  echo "Downloading... $filename"
  curl -s "$url" \
    | jq -r --arg filename "$filename" '.assets[] | select(.name == $filename) | .browser_download_url' \
    | wget -i- -q --show-progress -P "$tmp"

  pushd $tmp
  extract $filename
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
}

echo "ohmyzsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  /bin/zsh -i -c 'omz update'
else
  echo "Installing oh-my-zsh"
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

OH_MY_ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
## p10k
echo "p10k"
if [ -d "$OH_MY_ZSH_CUSTOM_DIR/themes/powerlevel10k" ]; then
  git -C "$OH_MY_ZSH_CUSTOM_DIR/themes/powerlevel10k" pull --rebase --force
else
  echo "Installing p10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$OH_MY_ZSH_CUSTOM_DIR/themes/powerlevel10k"
fi

## zsh-autosuggestions
ZSH_AUTOSUGGESTIONS_DIR="$OH_MY_ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
echo "zsh-autosuggestions"
if [ -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
  git -C "$ZSH_AUTOSUGGESTIONS_DIR" pull --rebase --force
else
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
fi

## zsh-syntax-highlighting
ZSH_SYNTAX_HIGHLIGHTING_DIR="$OH_MY_ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
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
"$FZF_DIR/install" --all --key-bindings --completion --no-update-rc

## fd
echo "fd"
install_from_github sharkdp/fd

## fnm
echo "fnm"
install_from_github Schniz/fnm

## nvim
echo "nvim"
install_from_github neovim/neovim