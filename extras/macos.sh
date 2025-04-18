# Set a fast keyboard repeat rate
defaults write -g InitialKeyRepeat -int 25
defaults write -g KeyRepeat -int 2

# Enable key repeat
defaults write -g ApplePressAndHoldEnabled -bool false

# Finder: allow quiting via ⌘ + Q; doing so will also hide desktop icons
# defaults write com.apple.finder QuitMenuItem -bool true

# Finder: show all filename extensions in Finder
# defaults write -g AppleShowAllExtensions -bool true

# Finder: show status bar
# defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
# defaults write com.apple.finder ShowPathbar -bool true

## Dock, Dashboard, and hot corners

# Set the icon size of Dock items to 36 pixels
defaults write com.apple.dock "tilesize" -int 40

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.15

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Remove the auto-hiding Dock delay
defaults write com.apple.dock "autohide-delay" -float 0

# Do not display recent applications in Dock
defaults write com.apple.dock "show-recents" -bool "false"
