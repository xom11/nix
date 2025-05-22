## Plugin
# blind
u       tmux-fzf-url
F       tmmx-fzf
y       copy command line (normal)
Y       put selection (copy mode)
o       sessionx
p       floax

# unblind
alt+p   floax

## Aliases

| Alias      | Command                    | Description                                              |
| ---------- | -------------------------- | -------------------------------------------------------- |
| `ta`       | tmux attach -t             | Attach new tmux session to already running named session |
| `tad`      | tmux attach -d -t          | Detach named tmux session                                |
| `tds`      | `_tmux_directory_session`  | Creates or attaches to a session for the current path    |
| `tkss`     | tmux kill-session -t       | Terminate named running tmux session                     |
| `tksv`     | tmux kill-server           | Terminate all running tmux sessions                      |
| `tl`       | tmux list-sessions         | Displays a list of running tmux sessions                 |
| `tmux`     | `_zsh_tmux_plugin_run`     | Start a new tmux session                                 |
| `tmuxconf` | `$EDITOR $ZSH_TMUX_CONFIG` | Open .tmux.conf file with an editor                      |
| `ts`       | tmux new-session -s        | Create a new named tmux session                          |