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

declare -Ar apps=(
  [fd]="sharkdp/fd"
  [fnm]="Schniz/fnm"
  [exa]="ogham/exa"
  [bat]="sharkdp/bat"
  [gh]="cli/cli"
)

for key in ${!apps[@]}; do
  printf "%s -> %s\n" "$key" "${apps[$key]}"
done
read -r -p "Do you want to install these apps? [y/N] " response

if [[ $response =~ ^[Yy]$ ]]; then
  case "$(uname -s)" in
  'Linux')
    for key in ${!apps[@]}; do
      downgit ${apps[$key]} "${APP_BIN_DIR}"
    done
    ;;
  'Darwin')
    brew install ${!apps[@]}
    ;;
  *)
    __error "Unsupported OS"
    exit 1
    ;;
  esac
fi

# UNIVERSAL
__log "UNIVERSAL"

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
