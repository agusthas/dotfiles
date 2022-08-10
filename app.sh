#!/usr/bin/env bash

APP_BIN_DIR=${APP_BIN_DIR:-$HOME/bin}

# region Helpers
__log() {
  echo -e "$1"
}

__info() {
  echo -e "[INFO] $1"
}

__completed() {
  echo -e "[✓] $1"
}

__error() {
  echo -e "[ERROR] $1"
}

__warn() {
  echo -e "[WARN] $1"
}
# endregion

# START FROM HERE (PLATFORM SPECIFIC)

# SPACES here is important!
packages=(
  "fd sharkdp/fd"
  "fnm Schniz/fnm"
  "exa ogham/exa"
  "bat sharkdp/bat"
  "gh cli/cli"
)

printf "%s\n" "${packages[@]}" | (echo "NAME URL" && cat) | column -t -s " "

read -r -p "Do you want to install these apps? [y/N] " response

if [[ $response =~ ^[Yy]$ ]]; then
  case "$(uname -s)" in
  'Linux')
    for package in "${packages[@]}"; do
      url=$(echo "$package" | awk '{print $2}')
      downgit $url "${APP_BIN_DIR}"
    done
    ;;
  'Darwin')
    printf "%s\n" "${packages[@]}" \
      | awk '{print $1}' \
      | xargs brew install
    ;;
  *)
    __error "Unsupported OS"
    exit 1
    ;;
  esac
fi

# UNIVERSAL
__log "UNIVERSAL"

__info "oh-my-tmux"
OMT_DIR="$HOME/.oh-my-tmux"
if [ -d "$OMT_DIR" ]; then
  git -C "$OMT_DIR" pull --rebase --force
else
  git clone --depth=1 https://github.com/gpakosz/.tmux "$OMT_DIR" && ln -s -f "$OMT_DIR/.tmux.conf" "$HOME/.tmux.conf"
fi

__info "oh-my-zsh"
OMZ_DIR="$HOME/.oh-my-zsh"
if [[ ! -d "$OMZ_DIR" ]]; then
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
else
  echo "Already up to date."
fi

__info "p10k"
omz_custom_dir="${ZSH_CUSTOM:-$OMZ_DIR/custom}"
P10K_DIR="$omz_custom_dir/themes/powerlevel10k"
if [ -d "$P10K_DIR" ]; then
  git -C "$P10K_DIR" pull --rebase --force
else
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

__info "forgit"
FORGIT_DIR="$omz_custom_dir/plugins/forgit"
if [ -d "$FORGIT_DIR" ]; then
  git -C "$FORGIT_DIR" pull --rebase --force
else
  git clone --depth=1 https://github.com/wfxr/forgit "$FORGIT_DIR"
fi

__info "zsh-autosuggestions"
ZSH_AUTOSUGGESTIONS_DIR="$omz_custom_dir/plugins/zsh-autosuggestions"
if [ -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
  git -C "$ZSH_AUTOSUGGESTIONS_DIR" pull --rebase --force
else
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
fi

__info "zsh-syntax-highlighting"
ZSH_SYNTAX_HIGHLIGHTING_DIR="$omz_custom_dir/plugins/zsh-syntax-highlighting"
if [ -d "$ZSH_SYNTAX_HIGHLIGHTING_DIR" ]; then
  git -C "$ZSH_SYNTAX_HIGHLIGHTING_DIR" pull --rebase --force
else
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_HIGHLIGHTING_DIR"
fi
