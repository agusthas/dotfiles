#!/usr/bin/env bash

echo "ohmyzsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  /bin/zsh -i -c 'omz update'
else
  echo "Installing oh-my-zsh"
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

OH_MY_ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

## p10k
echo "p10k"
if [ -d "$OH_MY_ZSH_CUSTOM_DIR/themes/powerlevel10k" ]; then
  git -C "$OH_MY_ZSH_CUSTOM_DIR/themes/powerlevel10k" pull --rebase --force
else
  echo "Installing p10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$OH_MY_ZSH_CUSTOM_DIR/themes/powerlevel10k"
fi

## zsh-autosuggestions
ZSH_AUTOSUGGESTIONS_DIR="$OH_MY_ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
echo "zsh-autosuggestions"
if [ -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
  git -C "$ZSH_AUTOSUGGESTIONS_DIR" pull --rebase --force
else
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
fi

## zsh-syntax-highlighting
ZSH_SYNTAX_HIGHLIGHTING_DIR="$OH_MY_ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
echo "zsh-syntax-highlighting"
if [ -d "$ZSH_SYNTAX_HIGHLIGHTING_DIR" ]; then
  git -C "$ZSH_SYNTAX_HIGHLIGHTING_DIR" pull --rebase --force
else
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_HIGHLIGHTING_DIR"
fi
