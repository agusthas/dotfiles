#!/usr/bin/env bash

set -o pipefail

# UTILITY
shw_white () {
  echo $(tput bold)$(tput setaf 7)"$@"$(tput sgr 0)
}

shw_norm () {
  echo $(tput setaf 0)"$@"$(tput sgr 0)
}

shw_info () {
  echo $(tput bold)$(tput setaf 4)"INFO:: $@"$(tput sgr 0)
}

shw_warn () {
  echo $(tput bold)$(tput setaf 3)"WARN:: $@"$(tput sgr 0)
}
shw_err ()  {
  echo $(tput bold)$(tput setaf 1)"ERROR:: $@"$(tput sgr 0)
}

prn_header() {
  echo
  shw_white "$1"
  echo "---------------------"
}

prn_footer() {
  echo "---------------------"
}

please_stow() {
  stow -d "$HOME/dotfiles" -t ~ "$1"
}
# END UTILITY

install_ohmyzsh() {
  prn_header "install oh-my-zsh"
  if [ ! -d $HOME/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    shw_warn "oh-my-zsh is already installed"
  fi

  shw_norm "Execute post install"
  rm -f "$HOME/.zshrc" # remove zshrc
  rm -f "$HOME/.zprofile" # remove zprofile
  rm -f "$HOME/.zshenv" # remove zshenv
  please_stow zsh

  prn_footer
}

install_powerlevel10k() {
  prn_header "install powerlevel10k"
  if [ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  else
    shw_warn "powerlevel10k is already installed"
    echo
    shw_norm "Updating powerlevel10k" 
    git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k pull
  fi

  shw_norm "Execute post install"
  rm -f "$HOME/.p10k.zsh" # remove p10k
  please_stow p10k

  prn_footer
}

install_fzf() {
  prn_header "install fzf"
  TARGET_DIR="$HOME/.fzf"
  if [ ! -d $HOME/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$TARGET_DIR"
  else
    shw_warn "fzf is already installed"
    echo
    shw_norm "Updating fzf" 
    git -C "$TARGET_DIR" pull
  fi
  ~/.fzf/install --completion --key-bindings --no-update-rc > /dev/null 2>&1

  prn_footer
}

install_fd() {
  prn_header "install fd"
  local TARGET_BIN_DIR="$HOME/bin"
  local D_URL="https://api.github.com/repos/sharkdp/fd/releases/latest"

  if compgen -G "$TARGET_BIN_DIR/fd*" > /dev/null; then
    shw_info "Found binary in $TARGET_BIN_DIR. Proceed to removing..."
    rm $TARGET_BIN_DIR/fd*
  fi
  echo

  TEMP_DIR="$(mktemp -d)"
  pushd $TEMP_DIR > /dev/null

  shw_norm "Download and install"
  if ! curl -s $D_URL | grep -wo 'https.*x86_64.*-linux-gnu.tar.gz' | wget -qi -; then
    shw_err "Failed to download"
  else
    local extracted=$(tar -tzf fd-* | head -n 1 | cut -f 1 -d '/')
    tar xzf fd-*
    mv "$extracted/fd" "$TARGET_BIN_DIR/fd"
    chmod +x "$TARGET_BIN_DIR/fd"
    shw_info "Installed in $TARGET_BIN_DIR"
  fi
  popd > /dev/null

  rm -r $TEMP_DIR
  prn_footer
}

install_fnm() {
  prn_header "install fnm"
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
  prn_footer
}

install_docker() {
  prn_header "install docker"
  if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
  else
    shw_warn "docker is already installed"
  fi

  shw_norm "Execute post install"
  cat << EOF
This post install for docker will:

1. Create docker group and add current user to the docker group (eliminating the need to sudo on docker command).
2. Configure log driver in /etc/docker/daemon.json to use local and a max size of 10m and max file of 3 (reducing the bloated log file of docker).

Some of this command is requires sudo and also requires you to not have ever configured docker except from installing.
If you already configured the docker to your likings, please answer no to the question below
EOF

  read -p "Do you want to proceed? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    shw_white "adding current user ($USER) to docker group (eliminating the need to sudo on docker command)"
    sudo groupadd docker
    sudo usermod -aG docker $USER

    shw_white "configuring log driver in /etc/docker/daemon.json to use local and a max size of 10m and max file of 3 (reducing the bloated log file of docker)"
    echo "{ \"log-driver\": \"local\", \"log-opts\": { \"max-size\": \"10m\", \"max-file\": \"3\" } }" | sudo tee /etc/docker/daemon.json
  fi

  prn_footer
}

install_nnn() {
  prn_header "install nnn"
  local TARGET_BIN_DIR="$HOME/bin"
  local D_URL="https://api.github.com/repos/jarun/nnn/releases/latest"

  shw_norm "Checking binaries in $TARGET_BIN_DIR"
  if compgen -G "$TARGET_BIN_DIR/nnn*" > /dev/null; then
    shw_info "Found binary in $TARGET_BIN_DIR. Proceed to removing..."
    rm $TARGET_BIN_DIR/nnn*
  fi
  echo

  TEMP_DIR="$(mktemp -d)"
  pushd $TEMP_DIR > /dev/null

  shw_norm "Download and install"
  if ! curl -s $D_URL | grep -wo 'https.*nnn-static*.*tar.gz' | wget -qi -; then
    shw_err "Failed to download"
  else
    tar xzf nnn-static-*
    mv nnn-static nnn
    mv nnn $TARGET_BIN_DIR
    chmod +x $TARGET_BIN_DIR/nnn
    shw_info "Installed in $TARGET_BIN_DIR"
  fi
  popd > /dev/null

  rm -r $TEMP_DIR
  prn_footer
}

install_nvim() {
  prn_header "install nvim"
  local TARGET_BIN_DIR="$HOME/bin"
  local D_URL="https://api.github.com/repos/neovim/neovim/releases/latest"

  shw_norm "Checking binaries in $TARGET_BIN_DIR"
  if compgen -G "$TARGET_BIN_DIR/nvim*" > /dev/null; then
    shw_info "Found binary in $TARGET_BIN_DIR. Proceed to removing..."
    rm $TARGET_BIN_DIR/nvim*
  fi
  echo

  TEMP_DIR="$(mktemp -d)"
  pushd $TEMP_DIR > /dev/null

  shw_norm "Download and install"
  if ! curl -s $D_URL | grep -wo '"https.*nvim\.appimage"' | tr -d '"' | wget -qi -; then
    shw_err "Failed to download"
  else
    mv nvim* $TARGET_BIN_DIR/nvim
    chmod +x $TARGET_BIN_DIR/nvim
    shw_info "Installed in $TARGET_BIN_DIR"
  fi
  popd > /dev/null

  rm -r $TEMP_DIR
  prn_footer
}

install_7z() {
  prn_header "install 7z"
  local TARGET_BIN_DIR="$HOME/bin"
  local D_URL="https://www.7-zip.org/a/7z2107-linux-x64.tar.xz"

  shw_norm "Checking binaries in $TARGET_BIN_DIR"
  if compgen -G "$TARGET_BIN_DIR/7z*" > /dev/null; then
    shw_info "Found binary in $TARGET_BIN_DIR. Proceed to removing..."
    rm $TARGET_BIN_DIR/7z*
  fi
  echo

  TEMP_DIR="$(mktemp -d)"
  pushd $TEMP_DIR > /dev/null
  
  shw_norm "Download and install"
  if ! wget -q $D_URL; then
    shw_err "Failed to download 7z"
  else
    tar xf 7z2107-linux-x64.tar.xz
    mv 7zzs $TARGET_BIN_DIR/7z
    chmod +x $TARGET_BIN_DIR/7z
    shw_info "Installed in $TARGET_BIN_DIR"
  fi
  popd > /dev/null

  rm -r $TEMP_DIR
  prn_footer
}

install_docker_compose() {
  prn_header "install docker-compose"
  DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
  local TARGET_BIN_DIR="$DOCKER_CONFIG/cli-plugins"
  if [ ! -d $TARGET_BIN_DIR ]; then
    mkdir -p $TARGET_BIN_DIR
  fi

  local D_URL="https://api.github.com/repos/docker/compose/releases/latest"

  shw_norm "Checking binaries in $TARGET_BIN_DIR"
  if compgen -G "$TARGET_BIN_DIR/docker-compose*" > /dev/null; then
    shw_info "Found binary in $TARGET_BIN_DIR. Proceed to removing..."
    rm $TARGET_BIN_DIR/docker-compose*
  fi
  echo

  TEMP_DIR="$(mktemp -d)"
  pushd $TEMP_DIR > /dev/null

  shw_norm "Downloading and install"
  if ! curl -s $D_URL | grep -wo '"https.*linux-x86_64"' | tr -d '"' | wget -qi -; then
    shw_err "Failed to download"
  else
    mv docker-compose* $TARGET_BIN_DIR/docker-compose
    chmod +x $TARGET_BIN_DIR/docker-compose
    shw_info "Installed in $TARGET_BIN_DIR"
  fi
  popd > /dev/null

  rm -r $TEMP_DIR
  prn_footer
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

  install_ohmyzsh
  install_powerlevel10k
  install_fzf
  install_fd
  install_fnm
  install_docker
  install_docker_compose
  install_nnn
  install_nvim
  install_7z

  echo
  shw_white "Installing done!"
}

main