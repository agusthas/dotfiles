# Notes on .gitconfig

## How to use custom ssh command?

```conf
# .gitconfig
[user]
  email = your@email.com

[core]
  sshCommand = ssh -i ~/.ssh/id_rsa
```

Then for every repo within the directory, it will use the custom ssh command.
