#!/usr/bin/env bash

echo "Need password to do apt update and apt upgrade"
echo

sudo apt update && sudo apt upgrade -y

LIST_OF_APPS="zsh zip unzip curl wget stow"

sudo apt install $LIST_OF_APPS

# create a bin directory in $HOME if it doesn't exist
if [ ! -d $HOME/bin ]; then
  mkdir $HOME/bin
fi

CURRENT_DEFAULT_SHELL=$(echo $SHELL)
echo
echo "Will change default shell to ZSH"
if grep -q "$CURRENT_DEFAULT_SHELL" <<< "zsh"; then
  chsh -s $(which zsh)
  echo
  echo "Default shell changed to ZSH"
else
  echo "Default shell is already zsh"
fi

echo
echo "Finished pre-install script"