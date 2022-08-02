#!/usr/bin/env bash

YES="Yes"
NO="No"
PATH=$PATH:$HOME/bin
APP_BIN_DIR=${APP_BIN_DIR:-$HOME/bin}

__log() {
  echo -e "$1"
}

__info() {
  echo -e "$(gum style --foreground 111 -- "$1")"
}

__completed() {
  echo -e "$(gum style --foreground 212 -- "[✓] $1")"
}

__error() {
  echo -e "$(gum style --foreground 196 -- "$1")"
}

__spinner() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s) shift; spinner="$1";;
      -t) shift; title="$1";;
      -c) shift; cmd="$1";;
      *) break;;
    esac
    shift
  done

  gum spin -s "${spinner:-line}" --title "${title:-"Doing Something..."}" -- "${cmd:-$@}"
}


USAGE() {
  cat <<EOF
$(gum style --foreground 3 -- "USAGE:"):
  $0 [options]

$(gum style --foreground 3 -- "OPTIONS:"):
  $(__info '-h, --help')
      Show this help message and exit.

  $(__info '--skip-binaries')
      Skip installing binaries.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      USAGE >&2
      exit 0
      ;;
    --skip-binaries)
      skip_binaries="$YES"
      shift
      ;;
  esac
  shift
done

gum style \
  --border normal \
  --margin "1 2" \
  --padding "1 2" \
  --align center \
  --border-foreground 212 \
  "$(gum style --bold 'Application Script Installer')" "" "[Linux | MacOS]"


# START FROM HERE (PLATFORM SPECIFIC)
if [[ -z "$skip_binaries" ]]; then
  __log "Skip installing binaries?"
  skip_binaries=$(gum choose $YES $NO --cursor "[✓] ") || exit 1
  __info "$skip_binaries\n"
fi

if ! [[ "$skip_binaries" = "$YES" ]]; then
  case "$(uname -s)" in
    'Linux')
      downgit sharkdp/fd
      downgit Schniz/fnm
      downgit -c "nvim" neovim/neovim
      downgit ogham/exa
      downgit sharkdp/bat
      downgit -c "gh" cli/cli
      ;;
    'Darwin')
      brew install bat fd fnm neovim exa gh
      ;;
    *)
      __log "Unsupported OS"
      exit 1
      ;;
  esac
fi

# UNIVERSAL
__log "UNIVERSAL"

OMZ_DIR="$HOME/.oh-my-zsh"
if [[ ! -d "$OMZ_DIR" ]]; then
  __spinner -t "Cloning..." git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
fi
__completed "oh-my-zsh"

omz_custom_dir="${ZSH_CUSTOM:-$OMZ_DIR/custom}"
## p10k
P10K_DIR="$omz_custom_dir/themes/powerlevel10k"
if [ -d "$P10K_DIR" ]; then
  __spinner -t "Updating..." git -C "$P10K_DIR" pull --rebase --force
else
  __spinner -t "Cloning..." git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi
__completed "p10k"

## zsh-autosuggestions
ZSH_AUTOSUGGESTIONS_DIR="$omz_custom_dir/plugins/zsh-autosuggestions"
if [ -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
  __spinner -t "Updating..." git -C "$ZSH_AUTOSUGGESTIONS_DIR" pull --rebase --force
else
  __spinner -t "Cloning..." git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
fi
__completed "zsh-autosuggestions"

## zsh-syntax-highlighting
ZSH_SYNTAX_HIGHLIGHTING_DIR="$omz_custom_dir/plugins/zsh-syntax-highlighting"
if [ -d "$ZSH_SYNTAX_HIGHLIGHTING_DIR" ]; then
  __spinner -t "Updating..." git -C "$ZSH_SYNTAX_HIGHLIGHTING_DIR" pull --rebase --force
else
  __spinner -t "Cloning..." git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_HIGHLIGHTING_DIR"
fi
__completed "zsh-syntax-highlighting"

## fzf
FZF_DIR="$HOME/.fzf"
if [ -d "$FZF_DIR" ]; then
  __spinner -t "Updating..." git -C "$FZF_DIR" pull --rebase --force
else
  __spinner -t "Cloning..." git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR"
fi
__completed "fzf"

__spinner "$FZF_DIR/install" --bin