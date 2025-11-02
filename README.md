# NeoVim Config

Lua based neovim config. 

Now based on https://github.com/nvim-lua/kickstart.nvim/tree/master.
- Follow kickstart's README.md for installations.

## Dependencies

```
sudo apt install python3-venv
```

## Portable Directory

For use in a network restricted environment:

https://github.com/RoryNesbitt/pvim

## Neovim Remote

First setup a venv for neovim-remote.

```bash
cd ~/.config/nvim
python3 -m venv venv
./venv/bin/pip install neovim-remote
```

This is used to prevent nested nvim sessions. Add the following to ~/.bashrc

```bash
if [ -n "${NVIM}" ]; then
  alias vimx='~/.config/nvim/venv/bin/nvr -o' # Open file in horizontal split
  alias vim='~/.config/nvim/venv/bin/nvr -O' # Open file in vertical split
  alias vimt='~/.config/nvim/venv/bin/nvr --remote-tab' # Open file in new tab
  export GIT_EDITOR='~/.config/nvim/venv/bin/nvr -cc split --remote-wait'
fi
```
