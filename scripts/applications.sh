#!/usr/bin/env bash

set -o pipefail
printf '\n'

# shellcheck disable=SC1091
source "$(dirname "$(readlink -f "$0")")/shared/functions.sh"

BIN_DIR="$HOME/bin"
mkdir -p "$BIN_DIR" &>/dev/null

FNM_DIR="$HOME/.fnm"
FZF_DIR="$HOME/.fzf"
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
COMPOSE_DIR="${DOCKER_CONFIG:-$HOME/.docker}/cli-plugins"

install_ohmyzsh() {
  TARGET_BIN_DIR="$HOME/.oh-my-zsh"

  info "Oh My Zsh"

  if has omz; then
    info "Oh My Zsh already installed"
    printf "\n"
    return 0
  fi

  if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
    error "Oh My Zsh installation failed"
    printf "\n"
    return 1
  fi

  completed "Oh My Zsh"
  printf "\n"
}

install_powerlevel10k() {
  url="https://github.com/romkatv/powerlevel10k.git"
  TARGET_BIN_DIR="$P10K_DIR"

  info "Powerlevel10k [${BLUE}${UNDERLINE}$url${NO_COLOR}]"
  if [ ! -d "$TARGET_BIN_DIR" ] && ! has p10k; then
    info "Installing Powerlevel10k"
    git clone --depth=1 "$url" "$TARGET_BIN_DIR"
  else
    info "Updating Powerlevel10k"
    git -C "$TARGET_BIN_DIR" pull --rebase --force > /dev/null 2>&1
  fi

  completed "Powerlevel10k"
  printf "\n"
}

install_fzf() {
  url="https://github.com/junegunn/fzf.git"
  TARGET_BIN_DIR="$FZF_DIR"

  info "FZF [${BLUE}${UNDERLINE}$url${NO_COLOR}]"
  if [ ! -d "$TARGET_BIN_DIR" ] && ! has fzf; then
    info "Installing FZF"
    git clone --depth 1 "$url" "$TARGET_BIN_DIR"
  else
    info "Updating FZF"
    git -C "$TARGET_BIN_DIR" pull --rebase --force > /dev/null 2>&1
  fi
  ~/.fzf/install --completion --key-bindings --no-update-rc > /dev/null 2>&1

  completed "FZF"
  printf "\n"
}

install_bat() {
  GH_REPO="sharkdp/bat"
  GH_ASSET_PATTERN="*x86_64*linux*musl.tar.gz"
  TARGET_BIN_DIR="$BIN_DIR"

  info "Bat [${BLUE}${UNDERLINE}$GH_REPO${NO_COLOR}]"

  tmp_dir=$(get_tmpdir)
  pushd "$tmp_dir" > /dev/null || return 1

  gh_download "$GH_REPO" "$GH_ASSET_PATTERN"

  EXECUTABLE=$(find . -type f -name "bat")
  if [ -z "$EXECUTABLE" ]; then
    error "Executable not found."
  fi

  if [ ! -f "$EXECUTABLE" ]; then
    error "Executable is not of type file."
  else
    NAME="bat"
    info "moving $(basename "$EXECUTABLE") binary as ${MAGENTA}${BOLD}$NAME${NO_COLOR} to ${CYAN}${UNDERLINE}$TARGET_BIN_DIR${NO_COLOR}."
    mv "$EXECUTABLE" "$TARGET_BIN_DIR/$NAME"
    chmod +x "$TARGET_BIN_DIR/$NAME"
  fi

  popd > /dev/null || return 1
  rm -r "$tmp_dir"

  completed "cleanup"
  printf "\n"
}

install_fd() {
  GH_REPO="sharkdp/fd"
  GH_ASSET_PATTERN="*x86_64*linux*musl.tar.gz"
  TARGET_BIN_DIR="$BIN_DIR"

  info "fd [${BLUE}${UNDERLINE}$GH_REPO${NO_COLOR}]"

  tmp_dir=$(get_tmpdir)
  pushd "$tmp_dir" > /dev/null || return 1

  gh_download "$GH_REPO" "$GH_ASSET_PATTERN"

  EXECUTABLE=$(find . -type f -name "fd")
  if [ -z "$EXECUTABLE" ]; then
    error "Executable not found."
  fi

  if [ ! -f "$EXECUTABLE" ]; then
    error "Executable is not of type file."
  else
    NAME="fd"
    info "moving $(basename "$EXECUTABLE") binary as ${MAGENTA}${BOLD}$NAME${NO_COLOR} to ${CYAN}${UNDERLINE}$TARGET_BIN_DIR${NO_COLOR}."
    mv "$EXECUTABLE" "$TARGET_BIN_DIR/$NAME"
    chmod +x "$TARGET_BIN_DIR/$NAME"
  fi

  popd > /dev/null || return 1
  rm -r "$tmp_dir"

  completed "cleanup"
  printf "\n"
}

install_fnm() {
  GH_REPO="Schniz/fnm"
  GH_ASSET_PATTERN="*linux*.zip"
  TARGET_BIN_DIR="$FNM_DIR"

  info "fnm [${BLUE}${UNDERLINE}$GH_REPO${NO_COLOR}]"

  mkdir -p "$TARGET_BIN_DIR" &>/dev/null

  tmp_dir=$(get_tmpdir)
  pushd "$tmp_dir" > /dev/null || return 1

  gh_download "$GH_REPO" "$GH_ASSET_PATTERN"

  EXECUTABLE=$(find . -type f -name "fnm")

  if [ -z "$EXECUTABLE" ]; then
    error "Executable not found."
  fi

  if [ -f "$EXECUTABLE" ]; then
    NAME="fnm"
    info "moving $(basename "$EXECUTABLE") binary as ${MAGENTA}${BOLD}$NAME${NO_COLOR} to ${CYAN}${UNDERLINE}$TARGET_BIN_DIR${NO_COLOR}."
    mv "$EXECUTABLE" "$TARGET_BIN_DIR/$NAME"
    chmod +x "$TARGET_BIN_DIR/$NAME"
  else
    error "Executable is not of type file."
  fi

  popd > /dev/null || return 1
  rm -r "$tmp_dir"

  completed "cleanup"
  printf "\n"
}

install_nnn() {
  GH_REPO="jarun/nnn"
  GH_ASSET_PATTERN="*nnn-static*.tar.gz"
  TARGET_BIN_DIR="$BIN_DIR"

  info "nnn [${BLUE}${UNDERLINE}$GH_REPO${NO_COLOR}]"

  tmp_dir=$(get_tmpdir)
  pushd "$tmp_dir" > /dev/null || return 1

  gh_download "$GH_REPO" "$GH_ASSET_PATTERN"

  EXECUTABLE=$(find . -type f -name "nnn-static")
  if [ -z "$EXECUTABLE" ]; then
    error "Executable not found."
  fi

  if [ ! -f "$EXECUTABLE" ]; then
    error "Executable is not of type file."
  else
    NAME="nnn"
    info "moving $(basename "$EXECUTABLE") binary as ${MAGENTA}${BOLD}$NAME${NO_COLOR} to ${CYAN}${UNDERLINE}$TARGET_BIN_DIR${NO_COLOR}."
    mv "$EXECUTABLE" "$TARGET_BIN_DIR/$NAME"
    chmod +x "$TARGET_BIN_DIR/$NAME"
  fi

  popd > /dev/null || return 1
  rm -r "$tmp_dir"

  completed "cleanup"
  printf "\n"
}

install_nvim() {
  GH_REPO="neovim/neovim"
  GH_ASSET_PATTERN="*nvim*.appimage"
  TARGET_BIN_DIR="$BIN_DIR"

  info "neovim [${BLUE}${UNDERLINE}$GH_REPO${NO_COLOR}]"

  tmp_dir=$(get_tmpdir)
  pushd "$tmp_dir" > /dev/null || return 1

  gh_download "$GH_REPO" "$GH_ASSET_PATTERN"

  EXECUTABLE=$(find . -type f -name "nvim.appimage")
  if [ -z "$EXECUTABLE" ]; then
    error "Executable not found."
  fi

  if [ ! -f "$EXECUTABLE" ]; then
    error "Executable is not of type file."
  else
    NAME="nvim"
    info "moving $(basename "$EXECUTABLE") binary as ${MAGENTA}${BOLD}$NAME${NO_COLOR} to ${CYAN}${UNDERLINE}$TARGET_BIN_DIR${NO_COLOR}."
    mv "$EXECUTABLE" "$TARGET_BIN_DIR/$NAME"
    chmod +x "$TARGET_BIN_DIR/$NAME"
  fi

  popd > /dev/null || return 1
  rm -r "$tmp_dir"

  completed "cleanup"
  printf "\n"
}

install_shellcheck() {
  GH_REPO="koalaman/shellcheck"
  GH_ASSET_PATTERN="*shellcheck*linux*x86_64*.tar.xz"
  TARGET_BIN_DIR="$BIN_DIR"

  info "shellcheck [${BLUE}${UNDERLINE}$GH_REPO${NO_COLOR}]"

  tmp_dir=$(get_tmpdir)
  pushd "$tmp_dir" > /dev/null || return 1

  gh_download "$GH_REPO" "$GH_ASSET_PATTERN"

  EXECUTABLE=$(find . -type f -name "shellcheck")
  if [ -z "$EXECUTABLE" ]; then
    error "Executable not found."
  fi

  if [ ! -f "$EXECUTABLE" ]; then
    error "Executable is not of type file."
  else
    NAME="shellcheck"
    info "moving $(basename "$EXECUTABLE") binary as ${MAGENTA}${BOLD}$NAME${NO_COLOR} to ${CYAN}${UNDERLINE}$TARGET_BIN_DIR${NO_COLOR}."
    mv "$EXECUTABLE" "$TARGET_BIN_DIR/$NAME"
    chmod +x "$TARGET_BIN_DIR/$NAME"
  fi

  popd > /dev/null || return 1
  rm -r "$tmp_dir"

  completed "cleanup"
  printf "\n"
}

install_delta() {
  GH_REPO="dandavison/delta"
  GH_ASSET_PATTERN="*delta*x86_64*linux*gnu.tar.gz"
  TARGET_BIN_DIR="$BIN_DIR"

  info "delta [${BLUE}${UNDERLINE}$GH_REPO${NO_COLOR}]"

  tmp_dir=$(get_tmpdir)
  pushd "$tmp_dir" > /dev/null || return 1

  gh_download "$GH_REPO" "$GH_ASSET_PATTERN"

  EXECUTABLE=$(find . -type f -name "delta")
  if [ -z "$EXECUTABLE" ]; then
    error "Executable not found."
  fi

  if [ ! -f "$EXECUTABLE" ]; then
    error "Executable is not of type file."
  else
    NAME="delta"
    info "moving $(basename "$EXECUTABLE") binary as ${MAGENTA}${BOLD}$NAME${NO_COLOR} to ${CYAN}${UNDERLINE}$TARGET_BIN_DIR${NO_COLOR}."
    mv "$EXECUTABLE" "$TARGET_BIN_DIR/$NAME"
    chmod +x "$TARGET_BIN_DIR/$NAME"
  fi

  popd > /dev/null || return 1
  rm -r "$tmp_dir"

  completed "cleanup"
  printf "\n"
}

install_docker_compose() {
  GH_REPO="docker/compose"
  GH_ASSET_PATTERN="*linux*x86_64"
  TARGET_BIN_DIR="${COMPOSE_DIR}"

  info "compose [${BLUE}${UNDERLINE}$GH_REPO${NO_COLOR}]"

  mkdir -p "$TARGET_BIN_DIR" &>/dev/null

  tmp_dir=$(get_tmpdir)
  pushd "$tmp_dir" > /dev/null || return 1

  gh_download "$GH_REPO" "$GH_ASSET_PATTERN"

  EXECUTABLE=$(find . -type f -name '*compose*')
  
  if [ -z "$EXECUTABLE" ]; then
    error "Executable not found."
  elif [ ! -f "$EXECUTABLE" ]; then
    error "Executable is not of type file."
  else
    NAME="docker-compose"
    info "moving $(basename "$EXECUTABLE") binary as ${MAGENTA}${BOLD}$NAME${NO_COLOR} to ${CYAN}${UNDERLINE}$TARGET_BIN_DIR${NO_COLOR}."
    mv "$EXECUTABLE" "$TARGET_BIN_DIR/$NAME"
    chmod +x "$TARGET_BIN_DIR/$NAME"
  fi

  popd > /dev/null || return 1
  rm -r "$tmp_dir"

  completed "cleanup"
  printf "\n"
}

install_7z() {
  # This is an external link (not as assets in github repo).
  # https://www.7-zip.org/download.html
  # therefore we need to _manually_ download the file and extract it.
  URL="https://www.7-zip.org/a/7z2107-linux-x64.tar.xz"
  OUTPUT=$(basename "$URL")
  TARGET_BIN_DIR="$BIN_DIR"

  info "7z [${BLUE}${UNDERLINE}$URL${NO_COLOR}]"

  tmp_dir=$(get_tmpdir)
  pushd "$tmp_dir" > /dev/null || return 1

  url_download "$URL" "$OUTPUT"
  EXECUTABLE=$(find . -maxdepth 2 -type  f -name "7zzs")

  if [ -z "$EXECUTABLE" ]; then
    error "Executable not found."
  fi

  if [ -f "$EXECUTABLE" ]; then
    NAME="7z"
    info "moving $(basename "$EXECUTABLE") binary as ${MAGENTA}${BOLD}$NAME${NO_COLOR} to ${CYAN}${UNDERLINE}$TARGET_BIN_DIR${NO_COLOR}."
    mv "$EXECUTABLE" "$TARGET_BIN_DIR/$NAME"
    chmod +x "$TARGET_BIN_DIR/$NAME"
  else
    error "Executable is not of type file."
  fi

  popd > /dev/null || return 1
  rm -r "$tmp_dir"

  completed "cleanup"
  printf "\n"
}

install_docker() {
  # This is an external link (not as assets in github repo).
  URL="https://get.docker.com"
  OUTPUT="get-docker.sh"

  info "docker [${BLUE}${UNDERLINE}$URL${NO_COLOR}]"

  if has docker; then
    info "docker is already installed."
    printf "\n"
    return 0
  fi

  tmp_dir=$(get_tmpdir)
  pushd "$tmp_dir" > /dev/null || return 1

  url_download "$URL" "$OUTPUT"
  EXECUTABLE=$(find . -maxdepth 2 -type  f -name "$OUTPUT")

  if [ -z "$EXECUTABLE" ]; then
    error "Executable not found."
  elif [ ! -f "$EXECUTABLE" ]; then
    error "Executable is not of type file."
  else
    # This is a shell script that needs to be executed.
    # It will install docker.
    info "executing: sh $OUTPUT"
    # sh "$OUTPUT"
  fi

  popd > /dev/null || return 1
  rm -r "$tmp_dir"

  completed "cleanup"
  printf "\n"
}

info "Installing applications..."
install_docker
install_ohmyzsh
install_powerlevel10k
install_fzf
install_nnn
install_nvim
install_fnm
install_fd
install_bat
install_7z
install_shellcheck
install_delta
install_docker_compose

printf "\n"
completed "Applications installed."
info "If you encounters error messages, please ${BOLD}FIX THE SCRIPTS!${NO_COLOR}"
echo "    Once you're done, run ${BOLD}\`applications.sh\`${NO_COLOR} to re-install the applications."
