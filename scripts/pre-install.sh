#!/usr/bin/env bash

echo "Need password to do apt update and apt upgrade"
echo

sudo apt update && sudo apt upgrade -y

LIST_OF_APPS="zsh zip unzip curl stow"

sudo apt install $LIST_OF_APPS

CURRENT_DEFAULT_SHELL=$(echo $SHELL)
echo
echo "Changing default shell to ZSH (need password to do this)"
if grep -q "$CURRENT_DEFAULT_SHELL" <<< "zsh"; then
  chsh -s $(which zsh)
  echo
  echo "Default shell changed to ZSH"
else
  echo "Default shell is already zsh"
fi

echo
echo "Finished pre-install script"