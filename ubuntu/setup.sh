#!/bin/sh

echo "Escalated permission are required to install base packages"
if ! sudo -v; then
  exit 1
fi
printf "\n"

# Update and upgrade packages
sudo apt update && sudo apt upgrade -y

# Installing base dependencies
echo "Installing dependencies..."
sudo apt install -y zsh \
  zip \
  unzip \
  curl \
  wget \
  stow \
  jq \
  tmux

## PPA Needed
# Git
echo "Installing Git PPA..."
sudo add-apt-repository ppa:git-core/ppa
sudo apt update; sudo apt install git
printf "\n"

# Github Cli
echo "Installing GitHub CLI..."
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
printf "\n"

if ! echo "$SHELL" | grep -q "zsh"; then
  echo "Please manually change shell to zsh."
  echo "You can do this by running:"
  echo "  chsh -s \$(which zsh)"
fi
printf "\n"