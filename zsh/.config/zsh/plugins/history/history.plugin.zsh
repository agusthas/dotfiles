function history-wrapper {
  local clear list stamp REPLY
  zparseopts -E -D c=clear l=list f=stamp E=stamp i=stamp t:=stamp

  if [[ -n $clear ]]; then
    # if -c provided

    # confirm action
    print -nu2 "Clear history? [y/N]: "
    builtin read -E
    [[ $REPLY = [yY] ]] || return 0

    print -nu2 >| "$HISTFILE"
    fc -p "$HISTFILE"

    print -u2 History file deleted.
  elif [[ $# -eq 0 ]]; then
    # if no arguments provided
    builtin fc $stamp -l 1
  else
    builtin fc $stamp -l "$@"
  fi
}

case ${HIST_STAMPS-} in
  "mm/dd/yyyy") alias history='history-wrapper -f' ;;
  "dd.mm.yyyy") alias history='history-wrapper -E' ;;
  "yyyy-mm-dd") alias history='history-wrapper -i' ;;
  "") alias history='history-wrapper' ;;
  *) alias history="history-wrapper -t '$HIST_STAMPS'" ;;
esac

[ -z "$HISTFILE" ] && HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
[ "$HISTSIZE" -lt 50000 ] && HISTSIZE=50000
[ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000

setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
# setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt SHARE_HISTORY             # Share history between all sessions.