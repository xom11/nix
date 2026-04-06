# Windows

## Reset Windows Without WiFi

Press `Shift + F10` to open CMD, then run:

```
OOBE\BYPASSNRO
```

## Create Symlink to WSL

```powershell
$target = (wsl -d Ubuntu wslpath -w "~/.nix").Trim()
New-Item -Path "$HOME\.nix" -ItemType SymbolicLink -Target $target
```

## Kanata

```powershell
kanata_windows_gui_winIOv2_cmd_allowed_x64.exe -c "$HOME\.nix\dotfiles\kanata\kanata.kbd"
```
