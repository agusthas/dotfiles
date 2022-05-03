#!/bin/sh

echo "Escalated permissions are required to install base packages and changing shell"
if ! sudo -v; then
  echo "This script requires elevated permissions. Please try again with sudo."
  exit 1
fi
printf "\n"

# Update and upgrade packages
sudo apt update && sudo apt upgrade -y

# Installing dependencies
sudo apt install -y zsh \
  zip \
  unzip \
  curl \
  wget \
  stow \
  jq

if ! command -v gh >/dev/null 2>&1; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install gh
fi

# If shell not zsh, change shell to zsh
if ! echo "$SHELL" | grep -q "zsh"; then
  echo "Changing shell to zsh"
  
  if ! sudo chsh -s "$(which zsh)"; then
    echo "Failed to change shell to zsh. Please try again with command 'chsh -s \$(which zsh)'"
    exit 1
  fi

  echo "Shell changed to zsh"
  echo "Please logout and login again to apply changes"
fi
