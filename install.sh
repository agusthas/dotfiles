#!/usr/bin/env bash

do_stow() {
  stow -d "$HOME/dotfiles" -t ~ "$1"
}

sudo apt update && sudo apt upgrade -y

# needed package for sure
sudo apt install zip unzip curl stow

if ! command -v git &> /dev/null; then
  sudo apt install git
fi

if ! command -v gh &> /dev/null; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install -y gh

  if [[ -f "$HOME/.gitconfig" ]]; then
    do_stow git
  fi

  gh auth

  ssh -T git@github.com
fi

if ! command -v zsh &> /dev/null; then
  echo "ZSH is not installed"

  while true; do
    read -r -n 1 -p "Would you like me to set it up? [y/n]: " REPLY
    case $REPLY in
      [yY]) echo ; install_zsh ;;
      [nN]) echo ; exit 0 ;;
      *) printf " \033[31m %s \n\033[0m" "invalid input"
    esac 
  done  
fi

# installing oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# installing powerlevel-10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
do_stow p10k

# Installing fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --no-update-rc

# Installing fnm
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

# Stow remaining binaries
do_stow binaries

# stow zsh
if [[ -f "$HOME/.zshrc" ]]; then
  rm -iv "$HOME/.zshrc"
fi
do_stow zsh

exit 0
