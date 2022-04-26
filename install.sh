#!/usr/bin/env bash

set -o pipefail
printf '\n'

#region UTILITY FUNCTIONS
BOLD="$(tput bold 2>/dev/null || printf '')"
GREY="$(tput setaf 0 2>/dev/null || printf '')"
UNDERLINE="$(tput smul 2>/dev/null || printf '')"
RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
BLUE="$(tput setaf 4 2>/dev/null || printf '')"
MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"
NO_COLOR="$(tput sgr0 2>/dev/null || printf '')"

info() {
  printf '%s\n' "${BOLD}${GREY}>${NO_COLOR} $*"
}

info_tabbed() {
  printf '  %s\n' "${BOLD}${GREY}>${NO_COLOR} $*"
}

warn() {
  printf '%s\n' "${YELLOW}! $*${NO_COLOR}"
}

error() {
  printf '%s\n' "${RED}x $*${NO_COLOR}" >&2
}

completed() {
  printf '%s\n' "${GREEN}✓${NO_COLOR} $*"
}

completed_tabbed() {
  printf '  %s\n' "${GREEN}✓${NO_COLOR} $*"
}

has() {
  command -v "$1" 1>/dev/null 2>&1
}

get_tmpdir() {
  dir_name=$(mktemp -d)
  printf "%s" "${dir_name}"
}

download() {
  file="$1"
  url="$2"

  wget -q -O $file $url
  rc=$?
  
  if [ $rc -ne 0 ]; then
    error "Failed to download $url"
    return $rc
  fi

  completed_tabbed "Downloaded"
  return 0
}

unpack() {
  archive=$1
  bin_dir=$2

  case "$archive" in
    *.tar.gz|*.tgz)
      tar xzf "${archive}" -C "${bin_dir:-.}"
      rc=$?
      ;;
    *.tar.xz)
      tar xf "${archive}" -C "${bin_dir:-.}"
      rc=$?
      ;;
    *.zip)
      unzip "${archive}" -d "${bin_dir:-.}"
      rc=$?
      ;;
    *)
      error "Unknown archive format: $archive"
      return 1
      ;;
  esac

  if [ $rc -ne 0 ]; then
    error "Failed to unpack $archive"
    return $rc
  fi

  completed_tabbed "Unpacked"
  return 0
}

config_stow() {
  stow -d "$HOME/dotfiles" -t ~ "$1"
}

force_pull() {
  git -C "$1" pull --rebase --force > /dev/null 2>&1
}

detect_platform() {
  platform="$(uname -s | tr '[:upper:]' '[:lower:]')"

  case "$platform" in
    darwin)
      platform="apple"
      ;;
    linux)
      platform="linux"
      ;;
    *)
      error "Unsupported platform: $platform"
      exit 1
      ;;
  esac

  printf "%s" "${platform}"
}

detect_arch() {
  arch="$(uname -m | tr '[:upper:]' '[:lower:]')"

  case "${arch}" in
    amd64) arch="x86_64" ;;
    armv*) arch="arm" ;;
    arm64) arch="aarch64" ;;
  esac

  # `uname -m` in some cases mis-reports 32-bit OS as 64-bit, so double check
  if [ "${arch}" = "x86_64" ] && [ "$(getconf LONG_BIT)" -eq 32 ]; then
    arch="i686"
  fi

  printf "%s" "${arch}"
}

detect_bin_dir() {
  bin_dir="$HOME/bin"

  if [ ! -d "$bin_dir" ]; then
    info "Installation location $bin_dir does not appear to be a directory. Creating..."
    mkdir -p "$bin_dir"
  fi

  # https://stackoverflow.com/a/11655875
  good=$(
    IFS=:
    for path in $PATH; do
      if [ "${path%/}" = "${bin_dir}" ]; then
        printf 1
        break
      fi
    done
  )

  if [ "${good}" != "1" ]; then
    warn "Bin directory ${bin_dir} is not in your \$PATH"
  fi

  printf "%s" "${bin_dir}"
}
#endregion

PLATFORM=$(detect_platform)
ARCH=$(detect_arch)
BIN_DIR=$(detect_bin_dir)

#region INSTALL FUNCTIONS
install_ohmyzsh() {
  target_dir="$HOME/.oh-my-zsh"

  info "Oh My Zsh"
  if [ ! "$target_dir" ] && [ ! has omz ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && completed "Oh My Zsh installed" || warn "Oh My Zsh installation failed"
  else
    completed_tabbed "Oh My Zsh is already installed"
  fi

  rm -f "$HOME/.zshrc" # remove zshrc
  rm -f "$HOME/.zprofile" # remove zprofile
  rm -f "$HOME/.zshenv" # remove zshenv
  config_stow zsh

  completed_tabbed "Post install done"
  printf "\n"
}

install_powerlevel10k() {
  url="https://github.com/romkatv/powerlevel10k.git"
  target_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

  info "Powerlevel10k [${BLUE}${UNDERLINE}$url${NO_COLOR}]"
  if [ ! -d "$target_dir" ] && [ ! has p10k ]; then
    git clone --depth=1 "$url" "$target_dir"
  else
    force_pull $target_dir && completed_tabbed "Pulled latest changes"
  fi

  rm -f "$HOME/.p10k.zsh" # remove p10k
  config_stow p10k

  completed_tabbed "Post install done"
  printf "\n"
}

install_fzf() {
  url="https://github.com/junegunn/fzf.git"
  target_dir="$HOME/.fzf"

  info "FZF [${BLUE}${UNDERLINE}$url${NO_COLOR}]"
  if [ ! -d $HOME/.fzf ] && [ ! has fzf ]; then
    git clone --depth 1 "$url" "$target_dir" && completed_tabbed "Cloned fzf"
  else
    force_pull $target_dir && completed_tabbed "Pulled latest changes"
  fi
  ~/.fzf/install --completion --key-bindings --no-update-rc > /dev/null 2>&1
  
  completed_tabbed "Post install done"
  printf "\n"
}

install_bat() {
  base_url="https://api.github.com/repos/sharkdp/bat/releases/latest"
  ext=".tar.gz"
  grep_pattern="https.*bat.*${ARCH}.*${PLATFORM}.*musl${ext}"
  url=$(curl -s $base_url | jq -r '.assets[].browser_download_url' | grep "${grep_pattern}")
  archive=$(basename $url)

  info "Bat [${BLUE}${UNDERLINE}$url${NO_COLOR}]"

  tmp_dir=$(get_tmpdir)
  pushd $tmp_dir > /dev/null

  download "$archive" "$url" || return 1

  unpack "$archive" || return 1

  extracted=$(ls -1 | grep -v "^$archive$")
  if [ ! -d "$extracted" ]; then
    error "Extracted archive not found"
    return 1
  fi

  mv -f "$extracted/bat" "$BIN_DIR/bat" \
    && chmod +x "$BIN_DIR/bat" \
    && completed_tabbed "Installed bat" \
    || error "Failed to install bat"

  popd > /dev/null
  rm -r $tmp_dir

  printf "\n"
}

install_fd() {
  base_url="https://api.github.com/repos/sharkdp/fd/releases/latest"
  ext=".tar.gz"
  grep_pattern="https.*fd.*${ARCH}.*${PLATFORM}.*musl${ext}"
  url=$(curl -s $base_url | jq -r '.assets[].browser_download_url' | grep "${grep_pattern}")
  archive=$(basename $url)

  local TARGET_BIN_DIR="$HOME/bin"

  info "fd [${BLUE}${UNDERLINE}$url${NO_COLOR}]"

  tmp_dir="$(get_tmpdir)"
  pushd $tmp_dir > /dev/null

  download "$archive" "$url" || return 1

  unpack "$archive" || return 1

  extracted=$(ls -1 | grep -v "^$archive$")
  if [ ! -d "$extracted" ]; then
    error "Extracted archive not found"
    return 1
  fi

  mv -f "$extracted/fd" "$TARGET_BIN_DIR/fd" \
    && chmod +x "$TARGET_BIN_DIR/fd" \
    && completed_tabbed "Installed" \
    || error "Failed to install fd"

  popd > /dev/null
  rm -r $tmp_dir

  printf "\n"
}

install_fnm() {
  url="https://fnm.vercel.app/install"
  info "fnm [${BLUE}${UNDERLINE}$url${NO_COLOR}]"
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell > /dev/null 2>&1
  completed_tabbed "Installed"

  printf "\n"
}

install_docker() {
  info "Docker"

  if ! has docker; then
    curl -fsSL https://get.docker.com | sh > /dev/null 2>&1
    completed_tabbed "Installed"

    cat << EOF
This post install for docker will:

1. Create docker group and add current user to the docker group (eliminating the need to sudo on docker command).
2. Configure log driver in /etc/docker/daemon.json to use local and a max size of 10m and max file of 3 (reducing the bloated log file of docker).

Some of this command is requires sudo and also requires you to not have ever configured docker except from installing.
If you already configured the docker to your likings, please answer no to the question below
EOF

    read -p "Do you want to proceed? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "adding current user ($USER) to docker group (eliminating the need to sudo on docker command)"
      sudo groupadd docker
      sudo usermod -aG docker $USER

      echo "configuring log driver in /etc/docker/daemon.json to use local and a max size of 10m and max file of 3 (reducing the bloated log file of docker)"
      echo "{ \"log-driver\": \"local\", \"log-opts\": { \"max-size\": \"10m\", \"max-file\": \"3\" } }" | sudo tee /etc/docker/daemon.json
      completed_tabbed "post install"
    fi
  else
    completed_tabbed "Already Installed"
  fi

  printf "\n"
}

install_nnn() {
  ext=".tar.gz"
  grep_pattern="https.*nnn-static.*${ext}"
  url=$(curl -s https://api.github.com/repos/jarun/nnn/releases/latest | jq -r '.assets[].browser_download_url' | grep "${grep_pattern}")
  archive=$(basename $url)

  info "nnn [${BLUE}${UNDERLINE}$url${NO_COLOR}]"

  tmp_dir="$(mktemp -d)"
  pushd $tmp_dir > /dev/null

  download "$archive" "$url" || return 1

  unpack "$archive" || return 1
  extracted=$(ls -1 | grep -v "^$archive$")
  if [ ! -f "$extracted" ]; then
    error "Extracted archive not found"
    return 1
  fi

  mv -f $extracted "$BIN_DIR/nnn" \
    && chmod +x "$BIN_DIR/nnn" \
    && completed_tabbed "Installed" \
    || error "Failed to install nnn"

  popd > /dev/null
  rm -r $tmp_dir
  
  printf "\n"
}

install_nvim() {
  base_url="https://api.github.com/repos/neovim/neovim/releases/latest"
  ext=".appimage"
  grep_pattern="https.*nvim*${ext}$"
  url=$(curl -s $base_url | jq -r '.assets[].browser_download_url' | grep "${grep_pattern}")
  archive=$(basename $url)

  info "nvim [${BLUE}${UNDERLINE}$url${NO_COLOR}]"

  tmp_dir="$(mktemp -d)"
  pushd $tmp_dir > /dev/null

  # download to the temp file
  download "$archive" "$url" || return 1

  # move and rename nvim.appimage to BIN_DIR
  mv -f nvim* "$BIN_DIR/nvim" && chmod +x "$BIN_DIR/nvim" && completed_tabbed "Installed" || error "Failed to install nvim"

  popd > /dev/null
  rm -r $tmp_dir

  printf "\n" 
}

install_7z() {
  url="https://www.7-zip.org/a/7z2107-linux-x64.tar.xz"
  archive=$(basename $url)

  info "7z [${BLUE}${UNDERLINE}$url${NO_COLOR}]"

  tmp_dir="$(mktemp -d)"
  pushd $tmp_dir > /dev/null

  download "$archive" "$url" || return 1
  unpack 7z2107-linux-x64.tar.xz || return 1
  
  mv -f 7zzs $BIN_DIR/7z \
    && chmod +x "$BIN_DIR/7z" \
    && completed_tabbed "Installed" \
    || error "Failed to install 7z"

  popd > /dev/null
  rm -r $tmp_dir
  
  printf "\n"
}

install_docker_compose() {
  base_url="https://api.github.com/repos/docker/compose/releases/latest"
  grep_pattern="https.*${PLATFORM}-${ARCH}$"
  url=$(curl -s $base_url | jq -r '.assets[].browser_download_url' | grep "${grep_pattern}")
  target_dir="${DOCKER_CONFIG:-$HOME/.docker}/cli-plugins"
  if [ ! -d $target_dir ]; then
    mkdir -p $target_dir
  fi

  info "docker-compose [${BLUE}${UNDERLINE}$url${NO_COLOR}]"

  tmp_dir="$(mktemp -d)"
  pushd $tmp_dir > /dev/null

  download "$(basename $url)" "$url" || return 1

  mv -f "$(basename $url)" $target_dir/docker-compose \
    && chmod +x $target_dir/docker-compose \
    && completed_tabbed "Installed in ${GREEN}$target_dir${NO_COLOR}" \
    || error "Failed to install docker-compose"

  popd > /dev/null
  rm -r $tmp_dir
  
  printf "\n"
}

install_base_packages() {
  packages=( "zsh" "zip" "unzip" "curl" "wget" "stow" "jq" )

  warn "Escalated permissions are required to install base packages and change shell"
  if ! sudo -v; then
    error "Superuser not granted, aborting installation"
    exit 1
  fi
  info "sudo apt-get update"
  sudo apt-get update 2>&1 > /dev/null
  info "sudo apt-get upgrade"
  sudo apt-get upgrade -y 2>&1 > /dev/null

  for i in "${packages[@]}"; do
    if ! has $i; then
      info "sudo apt-get install -y $i"
      sudo apt-get install -y $i 2>&1 > /dev/null
    fi
  done

  if ! [[ $SHELL == *zsh* ]]; then
    chsh -s $(which zsh) || rc=$?

    if [[ $rc == 0 ]]; then
      completed "Default shell changed to ZSH"
      info "Please logout and login again to make the change effective"
      info "Rerun this script to continue"
      exit 0
    else
      error "Failed to change default shell to zsh"
      exit 1
    fi
  fi
}
#endregion

install_base_packages
install_ohmyzsh
install_powerlevel10k
install_fzf
install_bat
install_fd
install_fnm
install_docker
install_docker_compose
install_nnn
install_nvim
install_7z

printf '\n'
completed "All done."
