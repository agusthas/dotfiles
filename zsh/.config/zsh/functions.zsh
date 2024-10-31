#!/usr/bin/env zsh

function getIP() {
  ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
}
