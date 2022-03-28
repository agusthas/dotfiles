#!/usr/bin/env bash

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
    echo "Skip powerlevel-10k"
  fi
}

install_fzf() {
  if [ ! -d $HOME/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  else
    echo "Skip fzf"
  fi
}

install_fnm() {
  if [ ! -d ~/.fnm ]; then
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
  else
    echo "Skip fnm"
  fi
}

install_docker() {
  if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
  else
    echo "Skip docker"
  fi
}

install_docker_compose() {
  if ! command -v docker-compose &> /dev/null; then
    VERSION="1.29.2"
    TARGET_DIR=/usr/local/bin/docker-compose
    sudo curl -L "https://github.com/docker/compose/releases/download/$VERSION/docker-compose-$(uname -s)-$(uname -m)" -o $TARGET_DIR
  else
    echo "Skip docker-compose"
  fi
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
  install_fnm
  install_docker
  install_docker_compose

  echo
  echo "Installing done!"
}

main