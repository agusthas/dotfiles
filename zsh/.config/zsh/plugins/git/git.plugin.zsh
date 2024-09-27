function git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local branch
  for branch in dev devel develop development; do
    if command git show-ref -q --verify refs/heads/$branch; then
      echo $branch
      return 0
    fi
  done

  echo develop
  return 1
}

function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done

  echo master
  return 1
}


alias grt='cd "$(git rev-parse --show-toplevel || echo .)"'

alias g="git"
alias ga="git add"

alias gb="git branch"
alias gba="git branch -a"

alias gst="git status"

alias gc='git commit --verbose'
alias gcam="git commit --all --message"
alias gcan!="git commit --verbose --all --no-edit --amend"


alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'
alias gunwip='git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1'

alias glogg="git log --color=always --oneline --graph --pretty=format:'%Cred%h%Creset%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
alias glog="git log --color=always --oneline --date=short --pretty=format:'%Cred%h%Creset%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"

alias gfo="git fetch origin"
alias gpull="git pull"
alias gpush="git push"

alias gsw="git switch"
alias gswc="git switch --create"
alias gco="git checkout"
alias gcd='git switch $(git_develop_branch)'
alias gcm='git switch $(git_main_branch)'

alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtls='git worktree list'
alias gwtmv='git worktree move'
alias gwtrm='git worktree remove'

alias gclean="git reset --hard HEAD && git clean -df"
alias gpristine='git reset --hard && git clean --force -dfx'

alias ggzip='git archive --format zip --output /tmp/latest.zip HEAD'