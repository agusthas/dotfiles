#!/usr/bin/env zsh

## This file contains all the extra functions or configuration
typeset -U path
path+=($HOME/bin)

export FZF_COMPLETION_TRIGGER=','
function _fzf_compgen_path() {
  echo "$1"
  bfs -follow "$1" \
    -exclude -name .git -a -exclude -name .hg -exclude -name .svn -a \( -type d -o -type f -o -type l \) \
    -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
}
function _fzf_compgen_dir() {
  bfs -follow "$1" \
    -exclude -name .git -a -exclude -name .hg -exclude -name .svn -a -type d \
    -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@' 
}

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS"
--prompt='❯ '
--pointer='-'
--marker='+'
--tabstop=4
--color=dark
--color=hl:2:bold,fg+:4:bold,bg+:-1,hl+:2:bold,info:3:bold,border:8,prompt:2,pointer:5,marker:1,header:6
--bind 'ctrl-s:toggle,tab:down,btab:up,ctrl-d:preview-down,ctrl-u:preview-up'
"

# bind ctrl+f to run script command from ~/bin/tms
bindkey -s '^f' '~/bin/tms\n'
