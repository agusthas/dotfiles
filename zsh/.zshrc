# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git gh fnm fd pass fzf zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor
if command -v nvim >/dev/null 2>&1; then
  export EDITOR='nvim'
else 
  export EDITOR='vim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias :q="exit"
alias clr='clear; echo Currently logged in on $TTY, as $USERNAME in directory $PWD.'

alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
alias getrandom='openssl rand -base64 32'

function gmove() {
  local usage="Usage: gmove <new-branch> <ref-branch-name>"
  local new_branch="$1"
  local ref_branch="$2"
  if [ -z "$new_branch" ] || [ -z "$ref_branch" ]; then
    echo "$usage"
    return 1
  fi
  
  git stash -- $(git diff --staged --name-only) && gwip

  git branch $1 $2
  git switch $1
  git stash pop
}

function __docker_pre_test() {
  if [[ -z "$1" ]] && [[ $(docker ps --format '{{.Names}}') ]]; then
    return 0;
  fi

  if [[ ! -z "$1" ]] && [[ $(docker ps -a --format '{{.Names}}') ]]; then
    return 0;
  fi

  echo "No containers found";
  return 1;
}

function fds() {
  local format="table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Ports}}"

  __docker_pre_test \
    && docker ps --format "$format" \
      | fzf --multi --header-lines=1 --height=40% --reverse --no-info \
      | awk '{print $2}' \
      | while read -r name; do
          docker stop $name
        done 
}

function fdst() {
  local format="table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"

  __docker_pre_test "all" \
    && docker ps -a --format "$format" \
      | fzf --multi --header-lines=1 --height=40% --reverse --no-info \
      | awk '{print $2}' \
      | while read -r name; do
          docker start $name
        done
}

function fif() {
  if [ ! "$#" -gt 0 ]; then echo "Usage: fif <search-term>"; return 1; fi

  if ! command -v rg >/dev/null 2>&1; then
    echo "rg is not installed. Please install ripgrep."
    return 1
  fi

  rg --files-with-matches --no-messages "$1" | fzf --no-info \
    --header '?:toggle-preview' \
    --preview "rg --ignore-case --pretty --context 5 '$1' {}" \
    --bind='?:toggle-preview'
}

function fns() {
  local scripts script_name
  local run_cmd

  if ! cat package.json > /dev/null 2>&1; then echo "fns: Error: No package.json found."; return 1; fi
  scripts=$(jq -r '.scripts | to_entries[] | "\"\(.key)\": \"\(.value)\""' package.json | fzf --reverse --height=40%)

  if ! [[ -n "$scripts" ]]; then echo "fns: Error: No scripts found."; return 1; fi
  script_name=$(echo "$scripts" | awk -F ': ' '{gsub(/"/, "", $1); print $1}')

  if command -v yarn >/dev/null 2>&1; then
    run_cmd="yarn"
  elif command -v npm >/dev/null 2>&1; then
    run_cmd="npm run"
  else
    echo "fns: Error: No package manager found"
    return 1
  fi
  
  $run_cmd "$script_name"
}

function fzf_alias() {
  local selection=$(alias | fzf --query="$BUFFER" | sed -re 's/=.+$/ /')

  if [[ -n "$selection" ]]; then
    LBUFFER="$selection"

    zle reset-prompt
  fi
}


# Open tmux
function tmux_open() {
  local current_dir=$(basename "$PWD")
  local session_name=$(echo "$current_dir" | tr " " "_")

  if [[ -n "$TMUX" ]]; then
    echo "tmux_open: Error: Already in tmux session."
    return 1
  fi

  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    tmux new-session -s "$session_name" -d
  fi

  tmux attach -t "$session_name"
}
bindkey -s '^T' '^u tmux_open^M'

zle -N fzf_alias
bindkey -M emacs '\ea' fzf_alias


# Remove commented command from history
function zshaddhistory() {
  emulate -L zsh
  if ! [[ "$1" =~ "(^#\s+|^\s+#|^ |^clear)" ]] ; then
    print -sr -- "${1%%$'\n'}"
    fc -p
  else
    return 1
  fi
}

export NNN_PLUG='b:fzf-bookmarks;p:preview;f:quick-find'
function n() {
  # Block nesting of nnn in subshells
  if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
    echo "nnn is already running"
    return
  fi

  # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
  # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
  # see. To cd on quit only on ^G, remove the "export" and make sure not to
  # use a custom path, i.e. set NNN_TMPFILE *exactly* as follows:
  #     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
  NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

  # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
  # stty start undef
  # stty stop undef
  # stty lwrap undef
  # stty lnext undef

  nnn -aQ "$@"

  if [ -f "$NNN_TMPFILE" ]; then
    . "$NNN_TMPFILE"
    rm -f "$NNN_TMPFILE" > /dev/null
  fi
}

# fnm
eval "$(fnm env --use-on-cd)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
