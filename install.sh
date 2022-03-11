#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SELF_NAME=$(basename $0)

source ${SCRIPT_DIR}/scripts/logger.sh

SCRIPTENTRY

do_stow() {
  ENTRY
  stow -d "$HOME/dotfiles" -t ~ "$1"
  EXIT
}

install_needed_packages() {
  ENTRY
  # Inform user will install base-needed package
  NEEDED_PACKAGES="zip unzip curl stow fd-find"
  INFO "Installing $NEEDED_PACKAGES package in a few seconds"
  sleep 5

  sudo apt install $NEEDED_PACKAGES
  INFO "Downloaded $NEEDED_PACKAGES"

  [ -d $HOME/bin ] || mkdir ~/bin
  [ -f $HOME/bin/fd ] || ln -s $(which fdfind) ~/bin/fd
  INFO "Symlink-ed fd"
  sleep 2
  EXIT
}

install_zsh() {
  ENTRY

	sudo apt install zsh

  zsh --version

	chsh -s $(which zsh)
  INFO "Default shell changed to ZSH"
  EXIT
}

install_ohmyzsh() {
  ENTRY

  if [ ! -d $HOME/.oh-my-zsh ]; then
    INFO "Installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    INFO "Finish oh-my-zsh installation"
  else
    INFO "Skip oh-my-zsh"
  fi

  EXIT
}

install_powerlevel10k() {
  ENTRY

  if [ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ]; then
    INFO "Installing powerlevel-10k"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    INFO "Stowing p10k folder"
    do_stow p10k
    INFO "Finish powerlevel-10k installation"
  else
    INFO "Skip powerlevel-10k"
  fi

  EXIT
}

install_fzf() {
  ENTRY

  if [ ! -d $HOME/.fzf ]; then
    INFO "Installing fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    INFO "Running fzf installer"
    ~/.fzf/install --no-update-rc
    INFO "Finish fzf installation"
  else
    INFO "Skip fzf"
  fi

  EXIT
}

install_fnm() {
  ENTRY

  if [ ! -d ~/.fnm ]; then
    INFO "Installing fnm"
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    INFO "Finish fnm installation"
  else
    INFO "Skip fnm"
  fi

  EXIT
}

install_docker() {
  ENTRY

  if ! command -v docker &> /dev/null; then
    INFO "curl docker and automatically run shell"
    curl -fsSL https://get.docker.com | sh

    INFO "add current user ($USER) to docker group (eliminating the need to sudo on docker command)"
    sudo groupadd docker
    sudo usermod -aG docker $USER

    INFO "echo log driver config to etc/docker/daemon.json"
    [ -f /etc/docker/daemon.json ] || sudo touch /etc/docker/daemon.json
    echo "{ \"log-driver\": \"local\", \"log-opts\": { \"max-size\": \"10m\", \"max-file\": \"3\" } }" | sudo tee /etc/docker/daemon.json
  else
    INFO "Skip docker"
  fi

  EXIT
}

install_docker_compose() {
  ENTRY

  if ! command -v docker-compose &> /dev/null; then
    VERSION="1.29.2"
    TARGET_DIR=/usr/local/bin/docker-compose
    INFO "install docker compose $VERSION to target directory $TARGET_DIR"
    sudo curl -L "https://github.com/docker/compose/releases/download/$VERSION/docker-compose-$(uname -s)-$(uname -m)" -o $TARGET_DIR

    sudo chmod +x /usr/local/bin/docker-compose

    docker-compose --version
  else
    INFO "Skip docker-compose"
  fi

  EXIT
}

main() {
  ENTRY
  FLAG="true"
  while [[ $FLAG == "true" ]]; do
    read -r -n 1 -p "Would you like me to start installing? [y/n]: " REPLY
    case $REPLY in
      [yY]) echo ; FLAG="false" ;;
      [nN]) echo ; exit 0 ;;
      *) printf " \033[31m %s \n\033[0m" "invalid input"
    esac 
  done

  # Do update & upgrade just to be sure
  echo "Need password to do apt update and apt upgrade"
  DEBUG "User entered password"
  sudo apt update && sudo apt upgrade -y

 
  if ! command -v zsh &> /dev/null; then
    INFO "ZSH is not installed"

    while true; do
      read -r -n 1 -p "Would you like me to set it up? [y/n]: " REPLY
      case $REPLY in
        [yY]) echo ; install_zsh ;;
        [nN]) echo ; exit 0 ;;
        *) printf " \033[31m %s \n\033[0m" "invalid input"
      esac 
    done  
  fi

  simple_info_echo "I will start to install package in 5 seconds"
  simple_error_echo "If there's an error, please abort this!"
  
  for i in {5..0}; do
    simple_info_echo "$i"
    sleep 1
  done

  install_needed_packages
  install_ohmyzsh
  install_powerlevel10k
  install_fzf
  install_fnm

  INFO "remove .zsrhc and stow new one"
  if [[ -f "$HOME/.zshrc" ]]; then
    rm -iv "$HOME/.zshrc"
  fi
  do_stow zsh

  install_docker
  install_docker_compose

  INFO "All perfectly setup!"
  simple_info_echo "Some packages (like docker) need to be restarted to take effects!!"

  for i in {5..0}; do
    simple_info_echo "$i"
    sleep 1
  done  
  
  simple_success_echo "Exiting gracefully!"
  EXIT
}

main

SCRIPTEXIT