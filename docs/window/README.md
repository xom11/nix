- create symlink
```bash
$target = (wsl -d Ubuntu wslpath -w "~/.nix").Trim()
New-Item -Path "$HOME\.nix" -ItemType SymbolicLink -Target $target
```
- kanata
```bash
kanata_windows_gui_winIOv2_cmd_allowed_x64.exe -c "$HOME\.nix\dotfiles\kanata\kanata.kbd"
```
