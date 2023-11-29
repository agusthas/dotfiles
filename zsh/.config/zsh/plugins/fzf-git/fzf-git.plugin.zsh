# This is a copy of the fzf-git plugin, this helps to understand how it works
# and to make changes to it.

# This used many format strings from git.
# - cheatsheet: https://devhints.io/git-log-format
# - docs: https://git-scm.com/docs/pretty-formats

if [[ $# -eq 1 ]]; then
  branches() {
    git for-each-ref --sort=-creatordate --sort=-HEAD --color=always --format=$'%(refname) %(color:green)(%(creatordate:relative))\t%(color:blue)%(subject)%(color:reset)' |
      eval "$1" |
      sed 's#^refs/remotes/#\x1b[95mremote-branch\t\x1b[33m#; s#^refs/heads/#\x1b[92mbranch\t\x1b[33m#; s#^refs/tags/#\x1b[96mtag\t\x1b[33m#; s#refs/stash#\x1b[91mstash\t\x1b[33mrefs/stash#' |
      column -ts$'\t'
  }
  case "$1" in
    branches) 
      echo $'CTRL-O (open in browser) / ALT-A (show all branches)\n'
      branches 'grep -v "^refs/remote"'
      ;;
    all-branches)
      echo $'CTRL-O (open in browser)\n'
      branches 'cat'
      ;;
    nobeep) ;;
    *) exit 1 ;;
  esac
elif [[ $# -gt 1 ]]; then
  set -e

  branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
  if [[ $branch = HEAD ]]; then
    branch=$(git describe --exact-match --tags 2> /dev/null || git rev-parse --short HEAD)
  fi

  # Only supports GitHub for now
  case "$1" in
    commit)
      hash=$(grep -o "[a-f0-9]\{7,\}" <<< "$2")
      path=/commit/$hash
      ;;
    branch|remote-branch)
      branch=$(sed 's/^[* ]*//' <<< "$2" | cut -d' ' -f1)
      remote=$(git config branch."${branch}".remote || echo 'origin')
      branch=${branch#$remote/}
      path=/tree/$branch
      ;;
    *)    exit 1 ;;
  esac

  remote=${remote:-$(git config branch."${branch}".remote || echo 'origin')}
  remote_url=$(git remote get-url "$remote" 2> /dev/null || echo "$remote")

  if [[ $remote_url =~ ^git@ ]]; then
    url=${remote_url%.git}
    url=${url#git@}
    url=https://${url/://}
  elif [[ $remote_url =~ ^http ]]; then
    url=${remote_url%.git}
  fi

  case "$(uname -s)" in
    Darwin) open "$url$path"     ;;
    *)      xdg-open "$url$path" ;;
  esac
  exit 0
fi

# -----------------------------------------------------------------------------

if [[ $- =~ i ]]; then
  # Redefine this function to change the options
  _fzf_git_fzf() {
    fzf-tmux -p90%,90% -- \
      --layout=reverse --multi --height=80% --min-height=20 --border \
      --border-label-pos=2 \
      --preview-window='hidden' \
      --exact \
      --bind='ctrl-\:change-preview-window(down|)' "$@"
  }

  # Check if the current dir is a git repo
  _fzf_git_check() {
    git rev-parse HEAD > /dev/null 2>&1 && return

    [[ -n $TMUX ]] && tmux display-message "Not in a git repository"
    return 1
  }

  __fzf_git=${BASH_SOURCE[0]:-${(%):-%x}}
  __fzf_git=$(readlink -f "$__fzf_git" 2> /dev/null || /usr/bin/ruby --disable-gems -e 'puts File.expand_path(ARGV.first)' "$__fzf_git" 2> /dev/null)

  if [[ -z $_fzf_git_cat ]]; then
    # sometimes bat is installed as batcat
    export _fzf_git_cat="cat"
    _fzf_git_bat_options="--style='${BAT_STYLE:-full}' --color=always --pager=never"
    if command -v batcat > /dev/null; then
      _fzf_git_cat="batcat $_fzf_git_bat_options"
    elif command -v bat > /dev/null; then
      _fzf_git_cat="bat $_fzf_git_bat_options"
    fi
  fi

  _fzf_git_reflogs() {
    _fzf_git_check || return
    git reflog --color=always --format="%C(blue)%gD %C(yellow)%h%C(auto)%d %gs" | _fzf_git_fzf --ansi \
      --tiebreak=index \
      --border-label '<R> reflog' \
      --color hl:underline,hl+:underline \
      --preview 'git show --color=always {1}' "$@" |
    awk '{print $1}'
  }

  _fzf_git_log() {
    _fzf_git_check || return

    git log --color=always --oneline --date=short --pretty=format:'%Cred%h%Creset%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' | _fzf_git_fzf --ansi \
      --nth=2.. \
      --tiebreak=index \
      --color hl:underline,hl+:underline \
      --border-label '<L> log' \
      --preview 'git show --color=always {1}' "$@" |
    awk '{print $1}'
  }

  _fzf_git_branches() {
    _fzf_git_check || return
    bash "$__fzf_git" branches | _fzf_git_fzf --ansi \
      --nth 2 \
      --border-label '<B> branches' \
      --header-lines 2 \
      --color hl:underline,hl+:underline \
      --no-hscroll \
      --bind "ctrl-o:execute-silent:bash $__fzf_git {1} {2}" \
      --bind "alt-a:change-prompt(All branches> )+reload(bash $__fzf_git all-branches)" \
      --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%Cred%h%Creset%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" {2}' "$@" |
    awk '{print $2}'
  }

  if [[ -n "${ZSH_VERSION:-}" ]]; then
    __fzf_git_join() {
      local item
      while read item; do
        echo -n "${(q)item} " # quote each item, -n to not add a newline
      done
    }

    # fzf-git use a function to initialize the bindkey,
    # here we define each bindkey separately

    # bind '^g^h' to _fzf_git_reflogs
    fzf-git-reflogs-widget() {
      local result=$(_fzf_git_reflogs | __fzf_git_join)
      zle reset-prompt
      LBUFFER+=$result
    }
    zle -N fzf-git-reflogs-widget
    bindkey '^g^h' fzf-git-reflogs-widget
    bindkey '^gh' fzf-git-reflogs-widget

    # bind '^g^l' to _fzf_git_log
    fzf-git-log-widget() {
      local result=$(_fzf_git_log | __fzf_git_join)
      zle reset-prompt
      LBUFFER+=$result
    }
    zle -N fzf-git-log-widget
    bindkey '^g^l' fzf-git-log-widget
    bindkey '^gl' fzf-git-log-widget

    # bind '^g^b' to _fzf_git_branches
    fzf-git-branches-widget() {
      local result=$(_fzf_git_branches | __fzf_git_join)
      zle reset-prompt
      LBUFFER+=$result
    }
    zle -N fzf-git-branches-widget
    bindkey '^g^b' fzf-git-branches-widget
    bindkey '^gb' fzf-git-branches-widget
  fi
fi