# Instructions

## Installation

1. cd into `dotfiles` directory
1. Run pre-install scripts

   ```sh
   $ ./pre-install.sh
   ```

1. Run install scripts

   ```sh
   $ ./install.sh
   ```

1. Run post-install scripts
   ```sh
   $ ./post-install.sh
   ```

## Adding new package

1. Create an install function (named `install_<your-package-name>`) in [install.sh](./install.sh)
1. _(optional)_ package need some configuration:

   - create a folder in root with your package name and put the configuration files inside.

1. _(optional)_ package need a post install function (ex: `add user to docker group`, etc):

   - Create a function in [post-install.sh](./post-install.sh) name `setup_<your-package-name>`
   - Add the needed post install for the package
