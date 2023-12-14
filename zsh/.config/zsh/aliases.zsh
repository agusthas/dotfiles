#!/bin/sh

alias ll='ls -lh'
alias la='ls -lAh'

alias zsh-update-plugins="find "$HOME/.config/zsh/plugins" -type d -exec test -e '{}/.git' ';' -print0 | xargs -I {} -0 git -C {} pull -q"

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias :q="exit"

# GIT
alias g="git"
alias ga="git add"
alias gba="git branch -a"
alias gst="git status"
alias gc="git commit -v"
alias groot='cd "$(git rev-parse --show-toplevel || echo .)"'
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'
alias gunwip='git log -n 1 | grep -q -c "\--wip--" && git reset HEAD~1'
alias glog="git log --oneline --graph --pretty=format:'%Cred%h%Creset%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
alias gsw="git switch"
alias gfo="git fetch origin"
alias gclean="git reset --hard HEAD && git clean -df"
alias gpristine='git reset --hard && git clean --force -dfx'

# alias getrandom='openssl rand -base64 32' 