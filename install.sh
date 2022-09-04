#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

shared_packages=(
  "zsh"
  "jq"
  "tmux"
  "git"
  "httpie"
  "stow"
  "fzf"
  "bat"
)

apt_packages=(
  "${shared_packages[@]}"
  "zip"
  "unzip"
  "curl"
  "fd-find"
)

brew_packages=(
  "fd"
  "fnm"
)

# Generate ASCII Text
if ! type base64 gunzip >/dev/null; then
  echo "= INSTALL.SH ="
else
  base64 -d <<<"H4sIAKGGEWMAA51NwRHAMAj6OwXP9uVCuWMRhy+YmAHqeUgECQCqQM9DOQPo7UWM2R1A6p2JSggp2inmKKvSDzZpyR06GyG5sMZnj07FNTc60g6HCkI7f5RlFHXCgWJ5tQXmw3fMbQn8rg8Stz4QJgEAAA==" | gunzip
fi
printf "\n"

case "$(uname -s)" in
'Linux')
  echo "======= LINUX ======="
  echo "Escalated permission are required to install base packages"
  if ! sudo -v; then
    exit 1
  fi
  printf "\n"

  echo "PRE COMMANDS"
  # git
  sudo add-apt-repository --no-update -y ppa:git-core/ppa

  # httpie
  echo && echo "Adding httpie sources list"
  curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/httpie.gpg
  echo "deb [signed-by=/etc/apt/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" | sudo tee /etc/apt/sources.list.d/httpie.list >/dev/null

  # Installing base dependencies
  echo && echo "Installing dependencies..."
  sudo apt-get update && sudo apt-get upgrade -y # Update and upgrade packages
  sudo apt-get install -y "${apt_packages[@]}"

  # post-commands for several packages
  echo && echo "POST COMMANDS"
  # bat
  echo "[INFO] Creating batcat alias..."
  ln -s $(which batcat) ~/bin/bat

  # fd
  echo "[INFO] Creating fdfind alias..."
  ln -s $(which fdfind) ~/bin/fd

  # fnm
  if ! type fnm >/dev/null; then
    echo "[INFO] Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$HOME/bin" --skip-shell
  fi

  if ! echo "$SHELL" | grep -q "zsh"; then
    echo "Please manually change shell to zsh."
    echo "You can do this by running:"
    echo "  chsh -s \$(which zsh)"
    exit 1
  fi
  ;;
'Darwin')
  echo "======= MAC ======="
  brew install "${brew_packages[@]}"
  ;;
*)
  echo "Unsupported OS"
  exit 1
  ;;
esac

echo "[INFO]" "oh-my-tmux"
omt_install_dir="$HOME/.oh-my-tmux"
if [ -d "$omt_install_dir" ]; then
  git -C "$omt_install_dir" pull --rebase --force
else
  git clone --depth=1 https://github.com/gpakosz/.tmux "$omt_install_dir" \
    && ln -s -f "$omt_install_dir/.tmux.conf" "$HOME/.tmux.conf"
fi

echo "[INFO]" "oh-my-zsh"
omz_install_dir="$HOME/.oh-my-zsh"
if [[ ! -d "$omz_install_dir" ]]; then
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$omz_install_dir"
else
  zsh -ic 'omz update'
fi

echo "Installing zsh plugins and themes..."
omz_custom_dir="$omz_install_dir/custom"

echo "[INFO]" "p10k"
p10k_install_dir="$omz_custom_dir/themes/powerlevel10k"
if [ -d "$p10k_install_dir" ]; then
  git -C "$p10k_install_dir" pull --rebase --force
else
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_install_dir"
fi

echo "[INFO]" "zsh-autosuggestions"
zsh_autosuggest_install_dir="$omz_custom_dir/plugins/zsh-autosuggestions"
if [ -d "$zsh_autosuggest_install_dir" ]; then
  git -C "$zsh_autosuggest_install_dir" pull --rebase --force
else
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$zsh_autosuggest_install_dir"
fi

echo "[INFO]" "zsh-syntax-highlighting"
zsh_syntax_install_dir="$omz_custom_dir/plugins/zsh-syntax-highlighting"
if [ -d "$zsh_syntax_install_dir" ]; then
  git -C "$zsh_syntax_install_dir" pull --rebase --force
else
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_syntax_install_dir"
fi


/usr/bin/env bash -c "$SCRIPT_DIR/symlinks.sh"

echo "[install.sh] Done!"
