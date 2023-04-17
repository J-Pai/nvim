# NeoVim Config

Lua based neovim config.

## Dependencies

```
sudo apt install python3-venv
```

## Portable Directory

For use in a network restricted environment:

https://github.com/RoryNesbitt/pvim

## Neovim Remote

This is used to prevent nested nvim sessions. Add the following to ~/.bashrc

```bash
alias vim=nvim --remote /tmp/nvimsocket

if [ -n "${NVIM}" ]; then
  alias vimx='nvr -o' # Open file in horizontal split
  alias vim='nvr -O' # Open file in vertical split
  alias vimt='nvr --remote-tab' # Open file in new tab
  export GIT_EDITOR='nvr -cc split --remote-wait'
fi
```
