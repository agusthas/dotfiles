function fzf_setup_using_base_dir() {
  local fzf_base fzf_shell fzfdirs dir

  test -d "${FZF_BASE}" && fzf_base="${FZF_BASE}"

  if [[ -z "${fzf_base}" ]]; then
    fzfdirs=(
      "${HOME}/.fzf"
      "/opt/homebrew/opt/fzf"
    )
    for dir in ${fzfdirs}; do
      if [[ -d "${dir}" ]]; then
        fzf_base="${dir}"
        break
      fi
    done
  fi

  if [[ ! -d "${fzf_base}" ]]; then
    return 1
  fi

  # Fix fzf shell directory for Arch Linux, NixOS or Void Linux packages
  if [[ ! -d "${fzf_base}/shell" ]]; then
    fzf_shell="${fzf_base}"
  else
    fzf_shell="${fzf_base}/shell"
  fi

  # Setup fzf binary path
  if (( ! ${+commands[fzf]} )) && [[ "$PATH" != *$fzf_base/bin* ]]; then
    export PATH="$PATH:$fzf_base/bin"
  fi

  # Auto-completion
  if [[ -o interactive ]]; then
    source "${fzf_shell}/completion.zsh" 2> /dev/null
  fi

  # Key bindings
  source "${fzf_shell}/key-bindings.zsh"
}

function fzf_setup_error() {
  cat >&2 <<'EOF'
fzf plugin: Cannot find fzf installation directory.
Please add `export FZF_BASE=/path/to/fzf/install/dir` to your .zshrc
EOF
}

fzf_setup_using_base_dir \
  || fzf_setup_error

unset -f -m 'fzf_setup_*'

if [[ -z "$FZF_DEFAULT_COMMAND" ]]; then
  if (( $+commands[bfs] )); then
    export FZF_DEFAULT_COMMAND='bfs -type f -follow -exclude -name .git'
  elif (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  fi
fi
