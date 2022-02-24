#!/usr/bin/env bash

if ! command -v code &> /dev/null; then
  echo "code command not found."
  echo "Please run this script inside an already installed vscode"
  exit 0
fi

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

EXTENSION_FILE="$SCRIPTPATH/extension"

if [ -z "$EXTENSION_FILE" ]; then
  echo "Please create and input extension list separated by newline in /home/<username>/<path-to-dotfiles>/extension"
  exit 0
fi

while IFS= read -r line
do
  code --install-extension "$line"
done < "$EXTENSION_FILE"