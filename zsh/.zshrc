# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Supercharge (zsh setup and etc)
[ -d "$HOME/.config/zsh/plugins/supercharge" ] && source "$HOME/.config/zsh/plugins/supercharge/supercharge.plugin.zsh"

# Prompt
[ -d "$HOME/.config/zsh/plugins/powerlevel10k" ] && source "$HOME/.config/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme"

# FZF
[ -d "$HOME/.config/zsh/plugins/fzf" ] && source "$HOME/.config/zsh/plugins/fzf/fzf.plugin.zsh"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND -exclude -name node_modules"

# FZF-GIT
# [ -d "$HOME/.config/zsh/plugins/fzf-git" ] && source "$HOME/.config/zsh/plugins/fzf-git/fzf-git.plugin.zsh"

# source $ZSH/oh-my-zsh.sh

# Preferred editor
if command -v vim >/dev/null 2>&1; then
  export EDITOR='vim'
fi 

source "$HOME/.config/zsh/aliases.zsh"
source "$HOME/.config/zsh/profile.zsh"
# If you need to have a local .zsh_profile, create ~/.zsh_profile.local on your home directory
[[ ! -f ~/.zsh_profile.local ]] || source ~/.zsh_profile.local

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load Angular CLI autocompletion.
# source <(ng completion script)

# fnm
eval "$(fnm env --use-on-cd)"
