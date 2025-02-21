#!/usr/bin/env bash

set -euo pipefail  # Enable strict mode: exit on error, treat unset variables as errors, and catch pipeline failures

# Define colors for output
COLOR_RESET="\e[0m"
COLOR_INFO="\e[32m"  # Green
COLOR_WARN="\e[33m"  # Yellow
COLOR_ERROR="\e[31m"  # Red

log_info() {
  echo -e "\n${COLOR_INFO}[INFO] $1${COLOR_RESET}"
}

log_warn() {
  echo -e "\n${COLOR_WARN}[WARNING] $1${COLOR_RESET}"
}

log_error() {
  echo -e "\n${COLOR_ERROR}[ERROR] $1${COLOR_RESET}" >&2
}

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
OS=$(uname -s)

# Parse Flags
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-base)
        skip_base=true
        log_info "Skipping base installation."
        ;;
      --skip-symlinks)
        skip_symlinks=true
        log_info "Skipping symlink creation."
        ;;
      --symlinks)
        skip_base=true
        skip_extras=true
        log_info "Running in symlinks-only mode."
        ;;
      *)
        log_error "Unknown option: $1"
        exit 1
        ;;
    esac
    shift
  done
}

base_install() {
  log_info "Initializing base installation..."
  
  local shared_packages=("zsh" "tmux" "git" "stow" "bfs")
  local apt_packages=("${shared_packages[@]}" "curl" "zip" "unzip" "fd-find" "bat" "gojq" "ripgrep")
  local brew_packages=("${shared_packages[@]}" "fzf" "fd" "fnm" "starship" "zoxide")

  case "$OS" in
  'Linux')
    log_info "Detected Linux."
    if ! sudo -v; then
      log_error "Failed to obtain sudo permissions. Exiting..."
      exit 1
    fi

    if [[ ! -f "$HOME/.dotfiles-base-installed" ]]; then
      log_info "Adding required repositories..."
      sudo add-apt-repository --no-update -y ppa:git-core/ppa

      log_info "Updating and upgrading system packages..."
      sudo apt-get update && sudo apt-get upgrade -y

      log_info "Installing dependencies..."
      sudo apt-get install -y "${apt_packages[@]}"

      log_info "Setting up directories..."
      mkdir -pv ~/bin ~/work ~/sandbox

      touch $HOME/.dotfiles-base-installed
    fi

    if [[ "$SHELL" != *"zsh"* ]]; then
      log_warn "Default shell is not zsh. Change it using the following command:"
      echo "  chsh -s \$(which zsh)"
      exit 1
    fi

    log_info "Creating aliases..."
    ln -sf $(command -v batcat) ~/bin/bat || true
    ln -sf $(command -v fdfind) ~/bin/fd || true

    if ! command -v fzf &>/dev/null; then
      log_info "Installing fzf..."
      git clone --depth=1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
      "${HOME}/.fzf/install" --key-bindings --completion --no-update-rc
    fi
    
    if ! command -v zoxide &>/dev/null; then
      log_info "Installing zoxide..."
      curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi

    local FNM_PATH="$HOME/.local/share/fnm"
    if [[ ! -d "$FNM_PATH" ]]; then
      log_info "Installing fnm..."
      curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$HOME/.local/share/fnm" --skip-shell
    fi

    log_info "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh
    ;;
  'Darwin')
    log_info "Detected MacOS. Installing base packages..."
    brew install "${brew_packages[@]}"
    ;;
  *)
    log_error "Unsupported OS: $OS. Exiting..."
    exit 1
    ;;
  esac
}

create_symlinks() {
  log_info "Starting symlink creation..."
  local cmd="stow -d $SCRIPT_DIR -t $HOME --no-folding --verbose=1"
  mkdir -p "$HOME/bin" "$HOME/.config"

  log_info "Applying dotfiles configuration..."
  $cmd zsh git tmux vim starship scripts
  
  if [[ "$OS" == "Linux" ]]; then
    log_info "Applying Linux-specific configurations..."
    $cmd ubuntu 
  elif [[ "$OS" == "Darwin" ]]; then
    log_info "Applying MacOS-specific configurations..."
    $cmd macos
  fi
}

parse_args "$@"

[[ -z "${skip_base:-}" ]] && base_install
[[ -z "${skip_symlinks:-}" ]] && create_symlinks

log_info "Installation process completed successfully!"

