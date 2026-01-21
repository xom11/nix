# BUG: `ssh -> tmux -> nvim` share clipboard
- using osc 52 ( work in `ssh -> nvim` but not work in tmux )
- manual run `tmux refresh-client -l` to sync clipboard
- [url](https://github.com/neovim/neovim/discussions/29350#discussioncomment-10299517) for edit nvim

