# Lazygit configuration

This directory contains the configuration files for lazygit.

## MacOS Users

If using `homebrew` to install lazygit, the default configuration file is located at `~/Library/Application Support/lazygit/config.yml`.

You can use the following command to `ln` the configuration file to this directory:

```bash
# Delete the default configuration file if it exists
# rm $HOME/Library/Application\ Support/lazygit/config.yml
ln -s $HOME/.config/lazygit/config.yml $HOME/Library/Application\ Support/lazygit/config.yml
```