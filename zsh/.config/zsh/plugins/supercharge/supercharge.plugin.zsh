# completions
autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors 'di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zmodload zsh/complist
_comp_options+=(globdots)		# Include hidden files.
zle_highlight=('paste:none')
for dump in "${ZDOTDIR:-$HOME}/.zcompdump"(N.mh+24); do
  compinit
done
compinit -C

# unsetopt BEEP
setopt AUTO_CD
setopt GLOB_DOTS
setopt NOMATCH
setopt AUTO_MENU
# setopt MENU_COMPLETE
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS

# Colors
autoload -Uz colors && colors

# exports
export PATH="$HOME/.local/bin:$PATH"

# bindings

# Use emacs key bindings
bindkey -e

# Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# file rename magick
bindkey "^[m" copy-prev-shell-word

bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

bindkey -M menuselect '^[[Z' reverse-menu-complete
# bindkey -s '^x' '^usource $ZSHRC\n'
# bindkey -M menuselect '?' history-incremental-search-forward
# bindkey -M menuselect '/' history-incremental-search-backward
# bindkey '^H' backward-kill-word # Ctrl + Backspace to delete a whole word.

# compinit

# ls colors
case "$OSTYPE" in
	darwin*)  alias ls='ls -G' ;;
	linux*)   alias ls='ls --color=auto --group-directories-first' ;;
esac
