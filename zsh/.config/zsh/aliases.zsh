#!/bin/sh

alias ll='ls -lh'
alias la='ls -lAh'

# alias zsh-update-plugins="find "$HOME/.config/zsh/plugins" -type d -exec test -e '{}/.git' ';' -print0 | xargs -I {} -0 git -C {} pull -q"

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias :q="exit"
alias c="code"

# alias getrandom='openssl rand -base64 32' 