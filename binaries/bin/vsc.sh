#!/usr/bin/env bash

## Description: A script to open vscode based on selected fzf file/folder
## Author: SusuMantan<suzumantan@gmail.com>
## Dependencies:
##      - code
##      - fzf
##      - fd

FLAG=$1
QUERY=$2

STATIC_FOLDERS=( # List folders that you want them to appear as it is in fzf.
  "$HOME/dotfiles"
  "$HOME/bin"
)

root_folders=( # Folder list to be searched with --exact-depth 1
  "$HOME/delete-me"
  "$HOME/workspaces"
)

DYNAMIC_FOLDERS+=( $(fd . "${root_folders[@]}" --exact-depth 1 -t d) )

DIRECTORY_LIST=("${STATIC_FOLDERS[@]}" "${DYNAMIC_FOLDERS}")

TARGET_DIR=$(printf "%s\n" "${DIRECTORY_LIST[@]}" | fzf -q "$2")

if [ -z ${TARGET_DIR} ]; then
  echo "gracefully exits."
  exit 0;
fi

if [ "${FLAG}" == "-r" ]; then
  code -r ${TARGET_DIR}
elif [ "${n_flag}" == "-n" ]; then
  code -n ${TARGET_DIR}
else
  code ${TARGET_DIR}
fi

exit 0
