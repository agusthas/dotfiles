# Instructions

## Installation

1. cd into `dotfiles` directory
1. Run pre-install scripts

   ```bash
   $ ./scripts/pre-install.sh
   ```

1. Run install scripts

   ```bash
   $ ./scripts/install.sh
   ```

## Adding new package

1. Create an install function (named `install_<your-package-name>`) in [install.sh](./install.sh)
1. _(optional)_ package need some configuration:

   - create a folder in root with your package name and put the configuration files inside.
