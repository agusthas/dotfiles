typeset -U path
path=($HOME/bin "$path[@]")

# fnm
path=($HOME/.fnm "$path[@]")
eval "`fnm env`"
