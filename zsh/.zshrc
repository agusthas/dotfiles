# Supercharge (zsh setup and etc)
[ -d "$HOME/.config/zsh/plugins/supercharge" ] && source "$HOME/.config/zsh/plugins/supercharge/supercharge.plugin.zsh"

# FZF
[ -d "$HOME/.config/zsh/plugins/fzf" ] && source "$HOME/.config/zsh/plugins/fzf/fzf.plugin.zsh"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND -exclude -name node_modules"

# FZF-GIT
# [ -d "$HOME/.config/zsh/plugins/fzf-git" ] && source "$HOME/.config/zsh/plugins/fzf-git/fzf-git.plugin.zsh"

# Git
[ -d "$HOME/.config/zsh/plugins/git" ] && source "$HOME/.config/zsh/plugins/git/git.plugin.zsh"

# Preferred editor
if command -v vim >/dev/null 2>&1; then
  export EDITOR='vim'
fi 

source "$HOME/.config/zsh/aliases.zsh"
source "$HOME/.config/zsh/profile.zsh"
# If you need to have a local .zsh_profile, create ~/.zsh_profile.local on your home directory
[[ ! -f ~/.zsh_profile.local ]] || source ~/.zsh_profile.local

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi

# zoxide
eval "$(zoxide init zsh)"

# starship
eval "$(starship init zsh)"