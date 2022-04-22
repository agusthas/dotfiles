#!/usr/bin/env bash

ask() {
  local prompt default reply

  if [[ ${2:-} = 'Y' ]]; then
    prompt='(Default) Y/n'
    default='Y'
  elif [[ ${2:-} = 'N' ]]; then
    prompt='y/ (Default) N'
    default='N'
  else
    prompt='y/n'
    default=''
  fi

  while true; do
    echo -n "$1 [$prompt] "

    read -r reply </dev/tty

    # Default?
    if [[ -z $reply ]]; then
      reply=$default
    fi

    case "$reply" in
      Y*|y*) return 0 ;;
      N*|n*) return 1 ;;
    esac
  done
}

title_printer() {
  echo "------- SETUP: $1 -------"
}

please_stow() {
  stow -d "$HOME/dotfiles" -t ~ "$1"
}

setup_zshrc() {  
  title_printer "zshrc"

  local zshrc zshprofile
  zshrc="$HOME/.zshrc"
  zshprofile="$HOME/.zprofile"
  
  if [ -f $zshrc ] && [ -f $zshprofile ]; then
    if ask "Previous .zshrc configuration detected, would you like me to override it?" N; then
      rm -v $zshrc && rm -v $zshprofile && please_stow zsh
    else
      echo "Looks like there's already an .zshrc configuration. Please make sure your .zshrc is the same or at least similar to this repo .zshrc"
    fi
  else
    please_stow zsh
  fi
  
  echo "Finish setup zsh"
}

setup_p10k() {
  title_printer "p10k"

  local p10kconfig
  p10kconfig="$HOME/.p10k.zsh"

  if [ -f $p10kconfig ]; then
    if ask "Previous p10k configuration detected, would you like me to override it?"; then
      rm -v $p10kconfig && please_stow p10k
    else
      echo "Skip overriding"
    fi
  else
    please_stow p10k
  fi

  echo "Finish setup p10k"
}

setup_fzf() {
  title_printer "fzf"
  local TARGET_BIN_DIR="$HOME/bin"

  if ! command -v fzf &> /dev/null; then
    if ! command -v fdfind &> /dev/null; then
      echo "command fd not found"

      if ask "Instaling fd can improve fzf speed when searching files. Would you like me to install it? (need sudo password)" N; then
        sudo apt install fd-find
        ln -s $(which fdfind) $TARGET_BIN_DIR/fd
        echo "Finish installing fd"
      else
        echo "You can always install it later. Just follow the guide."
      fi
    fi
  else
    echo "Looks like FZF already installed as command. Please make sure you follow all the defaults."
  fi

  echo "Finish setup fzf"
}

setup_docker() {
  title_printer "Docker"

  local daemon_json
  daemon_json="/etc/docker/daemon.json"

  cat << EOF
This post install for docker will:

1. Create docker group and add current user to the docker group (eliminating the need to sudo on docker command).
2. Configure log driver in /etc/docker/daemon.json to use local and a max size of 10m and max file of 3 (reducing the bloated log file of docker).

Some of this command is requires sudo and also requires you to not have ever configured docker except from installing.
If you already configured the docker to your likings, please answer no to the question below
EOF

  if ask "Would you like to continue the docker post install?" N; then
    echo "adding current user ($USER) to docker group (eliminating the need to sudo on docker command)"
    sudo groupadd docker
    sudo usermod -aG docker $USER

    echo "echo log driver config to /etc/docker/daemon.json"
    [ -f $daemon_json ] || sudo touch $daemon_json
    echo "{ \"log-driver\": \"local\", \"log-opts\": { \"max-size\": \"10m\", \"max-file\": \"3\" } }" | sudo tee $daemon_json
  else
    echo "Skip post install Docker"
  fi

  echo "Finish setup docker"
}

setup_docker_compose() {
  title_printer "docker-compose"

  if command -v docker-compose &> /dev/null; then
    echo "docker-compose have been previously set up."

    docker-compose --version
  else
    if [ -f /usr/local/bin/docker-compose ]; then
      sudo chmod +x /usr/local/bin/docker-compose
      docker-compose --version
    else
      echo "Looks like i cannot found /usr/local/bin/docker-compose. If you can run docker-compose and have no problem with it, discard this message."
    fi
  fi 

  echo "Finish setup docker-compose"
}

main() {
  echo "------ POST-INSTALL SCRIPT ------"
  echo
  echo "Doing some setup for some packages"
  echo

  setup_zshrc
  echo

  setup_fzf
  echo

  setup_p10k
  echo

  setup_docker
  echo

  setup_docker_compose
  echo
}

main