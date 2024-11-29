# Supercharge (zsh setup and etc)
[ -d "$HOME/.config/zsh/plugins/supercharge" ] && source "$HOME/.config/zsh/plugins/supercharge/supercharge.plugin.zsh"

# FZF
[ -d "$HOME/.config/zsh/plugins/fzf" ] && source "$HOME/.config/zsh/plugins/fzf/fzf.plugin.zsh"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND -exclude -name node_modules"

# Git
[ -d "$HOME/.config/zsh/plugins/git" ] && source "$HOME/.config/zsh/plugins/git/git.plugin.zsh"

# Clipboard
[ -d "$HOME/.config/zsh/plugins/clipboard" ] && source "$HOME/.config/zsh/plugins/clipboard/clipboard.plugin.zsh"

# History
# [ -d "$HOME/.config/zsh/plugins/history" ] && source "$HOME/.config/zsh/plugins/history/history.plugin.zsh"

# FZF GIT
if [ -d "$HOME/.config/zsh/plugins/fzf-git" ]; then
  source "$HOME/.config/zsh/plugins/fzf-git/fzf-git.sh"
  _fzf_git_fzf() {
    fzf-tmux -p 100%,100% \
      --wrap \
      --layout=reverse --multi \
      --padding=1,0,0,0 \
      --border --border-label-pos=2 \
      --color='label:bold' \
      --preview-window='right,50%,border-left' \
      --bind='btab:up,double-click:ignore,tab:down' \
      --bind='ctrl-/:change-preview-window(down,50%,border-top|hidden|)' "$@"
  }
fi

# Preferred editor
if command -v vim >/dev/null 2>&1; then
  export EDITOR='vim'
fi 

source "$HOME/.config/zsh/aliases.zsh"
source "$HOME/.config/zsh/profile.zsh"
source "$HOME/.config/zsh/functions.zsh"
# If you need to have a local .zsh_profile, create ~/.zsh_profile.local on your home directory
[[ ! -f ~/.zsh_profile.local ]] || source ~/.zsh_profile.local

# go usr local directory (this is only in linux systems, on mac it's managed by homebrew)
GO_INSTALL_PATH="/usr/local/go/bin"
if [ -d "$GO_INSTALL_PATH" ]; then
  export PATH="$GO_INSTALL_PATH:$PATH"
fi

# go bin directory
GO_BIN_PATH="$HOME/go/bin"
if [ -d "$GO_BIN_PATH" ]; then
  export PATH="$GO_BIN_PATH:$PATH"
fi

# fnm
export FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
if [ -d "$BUN_INSTALL" ]; then
  export PATH="$BUN_INSTALL:$PATH"
fi

# zoxide
eval "$(zoxide init zsh)"

# starship
eval "$(starship init zsh)"
