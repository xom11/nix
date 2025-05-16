{ config, pkgs, ... }:

{
  programs.zsh.shellAliases = {
    f = "fzf";
    cat = "bat --paging=never --plain";
    fp = "fzf --preview=\"bat --color=always {}\"";
    vf = "nvim $(fzf -m --preview=\"bat --color=always {}\")";
    ls = "eza --icons --group-directories-first";
    lg = "lazygit";
    v = "nvim";
    vcf = "cd ~/.config/nvim && nvim";
    spy = "source .venv/bin/activate";
    cc = "conda create -p ./.venv python==3.12";
    ca = "conda activate ./.venv";
    gu = "git pull && git add . && git commit -m \"update\" && git push";
    py = "python3";
    py310 = "python3.10";
    nu = "nix run github:nix-community/home-manager -- switch --impure -b backup --flake ~/nix#nixos";
    osu = "sudo nixos-rebuild switch --impure --flake ~/nix#nixos";
  };
}