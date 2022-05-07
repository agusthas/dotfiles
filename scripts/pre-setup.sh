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
echo "Installing dependencies..."
sudo apt install -y zsh \
  zip \
  unzip \
  curl \
  wget \
  stow \
  jq \
  git \
  tmux

# Cloning dotfiles repository from github
echo "Cloning the dotfiles repository"
URL="https://github.com/agusthas/dotfiles.git"
git clone --depth 1 "$URL" "$HOME/dotfiles" || exit 1
printf "\n"

# GitHub CLI installation
echo "GitHub CLI installation"
if ! command -v gh >/dev/null 2>&1; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install gh
fi
printf "\n"

# If shell not zsh, WARN to change it
if ! echo "$SHELL" | grep -q "zsh"; then
  echo "Please manually change shell to zsh."
  echo "You can do this by running:"
  echo "  chsh -s \$(which zsh)"
fi
printf "\n"

echo "Done"
