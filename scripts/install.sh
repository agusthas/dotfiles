#!/usr/bin/env bash

set -o pipefail

install_ohmyzsh() {
  if [ ! -d $HOME/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    echo "Skip oh-my-zsh"
  fi
}

install_powerlevel10k() {
  if [ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  else
    git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k pull
  fi
}

install_fzf() {
  TARGET_DIR="$HOME/.fzf"
  if [ ! -d $HOME/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$TARGET_DIR"
  else
    git -C "$TARGET_DIR" pull
  fi

  ~/.fzf/install --completion --key-bindings --no-update-rc
}

install_fnm() {
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
}

install_docker() {
  if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
  else
    echo "Skip docker"
  fi
}

install_nnn() {
  local TARGET_BIN_DIR="$HOME/bin"
  local D_URL="https://api.github.com/repos/neovim/neovim/releases/latest"

  if find $TARGET_BIN_DIR -name 'nnn*'; then
    echo "Found nnn in $TARGET_BIN_DIR. Proceed to removing..."
    rm -v $TARGET_BIN_DIR/nnn*
  fi

  TEMP_DIR="$(mktemp -d)"
  pushd $TEMP_DIR > /dev/null
  echo "Downloading nnn in $PWD"

  if ! curl -s $D_URL | grep -wo 'https.*nnn-static*.*tar.gz' | wget -qi -; then
    echo "Failed to download nnn"
  else
    tar xzf nnn-static-*
    mv nnn-static nnn
    mv nnn $TARGET_BIN_DIR
    chmod +x $TARGET_BIN_DIR/nnn
    echo "nnn installed in $TARGET_BIN_DIR"
  fi
  popd > /dev/null

  echo "Cleaning up $TEMP_DIR"
  rm -rv $TEMP_DIR
}

install_nvim() {
  local TARGET_BIN_DIR="$HOME/bin"
  local D_URL="https://api.github.com/repos/neovim/neovim/releases/latest"

  if find $TARGET_BIN_DIR -name 'nvim*'; then
    echo "Found nvim in $TARGET_BIN_DIR. Proceed to removing..."
    rm -v $TARGET_BIN_DIR/nvim*
  fi

  TEMP_DIR="$(mktemp -d)"
  pushd $TEMP_DIR > /dev/null
  echo "Downloading nvim in $PWD"

  if ! curl -s $D_URL | grep -wo '"https.*nvim\.appimage"' | tr -d '"' | wget -qi -; then
    echo "Failed to download nvim"
  else
    mv nvim* $TARGET_BIN_DIR/nvim
    chmod +x $TARGET_BIN_DIR/nvim
    echo "nvim installed in $TARGET_BIN_DIR"
  fi
  popd > /dev/null

  echo "Cleaning up $TEMP_DIR"
  rm -rv $TEMP_DIR
}

install_7z() {
  local TARGET_BIN_DIR="$HOME/bin"
  local D_URL="https://www.7-zip.org/a/7z2107-linux-x64.tar.xz"

  if find $TARGET_BIN_DIR -name '7z*'; then
    echo "Found 7z in $TARGET_BIN_DIR. Proceed to removing..."
    rm -v $TARGET_BIN_DIR/7z*
  fi

  TEMP_DIR="$(mktemp -d)"
  pushd $TEMP_DIR > /dev/null
  echo "Downloading 7z in $PWD"

  if ! wget -q $D_URL; then
    echo "Failed to download 7z"
  else
    tar xf 7z2107-linux-x64.tar.xz
    mv 7zzs $TARGET_BIN_DIR/7z
    chmod +x $TARGET_BIN_DIR/7z
    echo "7z installed in $TARGET_BIN_DIR"
  fi
  popd > /dev/null

  echo "Cleaning up $TEMP_DIR"
  rm -rv $TEMP_DIR
}

install_docker_compose() {
  DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
  local TARGET_BIN_DIR="$DOCKER_CONFIG/cli-plugins"
  if [ ! -d $TARGET_BIN_DIR ]; then
    mkdir -p $TARGET_BIN_DIR
  fi

  local D_URL="https://api.github.com/repos/docker/compose/releases/latest"

  if find $TARGET_BIN_DIR -name 'docker-compose*'; then
    echo "Found compose in $TARGET_BIN_DIR. Proceed to removing..."
    rm -v $TARGET_BIN_DIR/docker-compose*
  fi

  TEMP_DIR="$(mktemp -d)"
  pushd $TEMP_DIR > /dev/null
  echo "Downloading compose in $PWD"

  if ! curl -s $D_URL | grep -wo '"https.*linux-x86_64"' | tr -d '"' | wget -qi -; then
    echo "Failed to download compose"
  else
    mv docker-compose* $TARGET_BIN_DIR/docker-compose
    chmod +x $TARGET_BIN_DIR/docker-compose
    echo "compose installed in $TARGET_BIN_DIR"
  fi
  popd > /dev/null

  echo "Cleaning up $TEMP_DIR"
  rm -rv $TEMP_DIR
}

main() {
  FLAG="true"
  while [[ $FLAG == "true" ]]; do
    read -r -n 1 -p "Would you like me to start installing? (Make sure you know what you are doing!) [y/n]: " REPLY
    case $REPLY in
      [yY]) echo ; FLAG="false" ;;
      [nN]) echo ; exit 0 ;;
      *) printf " \033[31m %s \n\033[0m" "invalid input"
    esac 
  done

  # install_ohmyzsh
  install_powerlevel10k
  install_fzf
  # install_fnm
  # install_docker
  # install_docker_compose
  # install_nnn
  # install_nvim
  # install_7z

  echo
  echo "Installing done!"
}

main