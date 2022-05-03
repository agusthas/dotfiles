# DOTFILES

**This repository is intended as a backup for my ubuntu-server configuration and packages, and as such not tested nor is this safe to run on any platform.**

## Never trust any scripts that you run!

Please make sure you check the scripts first before executing them. Some of them include `sudo` permission to run.

## Installation

**Requirements**:

- bare ubuntu-server (experimented on `focal` or `20.04`).
- An account on GitHub.

**Steps**:

1. pre-setup using the following command:

```sh
curl -fsS https://github.com/agusthas/dotfiles/blob/master/scripts/pre-setup.sh | sh
```

2. bootstrap the ubuntu-server:

```sh
cd $HOME/dotfiles # cd into the cloned repository from presetup
./scripts/setup.sh # run the setup scripts
```
