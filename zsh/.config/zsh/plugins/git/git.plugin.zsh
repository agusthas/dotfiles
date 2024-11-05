function git_current_branch() {
  command git rev-parse --abbrev-ref HEAD
}

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

function grename() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return
  local old_branch_name new_branch_name

  old_branch_name=$(git rev-parse --abbrev-ref HEAD)

  if [[ -z "$1" ]]; then
    echo "No new branch name provided"
    return 1
  fi

  new_branch_name="$1"

  echo "Renaming branch $old_branch_name to $new_branch_name"
  git branch -m "$old_branch_name" "$new_branch_name"

  # if user have --with-remote flag, replace the remote branch with the new branch
  if [[ $2 == "--with-remote" ]]; then
    upstream_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})

    # make sure upstream branch name is the same as old branch name
    is_upstream_branch_name_same=$(echo "$upstream_branch" | grep -o "$old_branch_name")
    if [ -z "$is_upstream_branch_name_same" ]; then
      echo "Upstream branch name is not the same as the old branch name"
      echo "Skipping pushing upstream branch"
      echo "If you still want to rename the upstream branch, run this command:"
      echo "  git push origin :$old_branch_name $new_branch_name"
      echo "  git push -u origin $new_branch_name"
      return 0
    fi

    echo
    echo "Updating upstream branch $upstream_branch to $new_branch_name"

    git push origin :"$old_branch_name" $new_branch_name
    git push -u origin "$new_branch_name"
  fi

  echo
  echo "Successfully renamed branch $old_branch_name to $new_branch_name"
}


alias grt='cd "$(git rev-parse --show-toplevel || echo .)"'
alias groot='cd "$(git rev-parse --show-toplevel || echo .)"'

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
alias gpsup='git push --set-upstream origin $(git_current_branch)'
alias gpsupf='git push --set-upstream origin $(git_current_branch) --force-with-lease'

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

alias groll='git reset --hard origin/$(git_current_branch)'
alias gclean="git reset --hard HEAD && git clean -df"
alias gpristine='git reset --hard && git clean --force -dfx'

alias ggzip='git archive --format zip --output /tmp/latest.zip HEAD'
