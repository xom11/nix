# desktop — Linux desktop (home-manager + system-manager)

User config — home-manager (shell alias: `update`):

```sh
home-manager switch --impure -b backup --flake ~/.nix#desktop
```

System config — system-manager (shell alias: `system-manager-update`):

```sh
sudo nix run 'github:numtide/system-manager' -- switch --flake ~/.nix#desktop
```
