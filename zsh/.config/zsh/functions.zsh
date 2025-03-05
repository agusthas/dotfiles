#!/usr/bin/env zsh

# A function to get the public IP address
# tested on WSL only
function getIP() {
  ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
}

# A function to open a man page in Preview.app
# Works on macOS only!
function pman() {
  mandoc -T pdf "$(/usr/bin/man -w $@)" | open -f -a Preview
}
