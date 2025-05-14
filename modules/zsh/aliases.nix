{ config, pkgs, ... }:

{
  programs.zsh.shellAliases = {
    cd = "z";
    f = "fzf";
    cat = "bat --paging=never --plain";
    fp = "fzf --preview=\"bat --color=always {}\"";
    vf = "nvim $(fzf -m --preview=\"bat --color=always {}\")";
    ls = "eza --icons --group-directories-first";
    v = "nvim";
    vcf = "cd ~/.config/nvim && nvim";
    vz = "nvim ~/.zshrc";
    sz = "source ~/.zshrc";
    spy = "source .venv/bin/activate";
    cc = "conda create -p ./.venv python==3.12";
    ca = "conda activate ./.venv";
    gcg = "git config --global user.name khanhkhanhlele && git config --global user.email namkhanh20xx@gmail.com";
    gcl = "git config --local user.name khanhkhanhlele && git config --local user.email namkhanh20xx@gmail.com";
    gu = "git pull && git add . && git commit -m \"update\" && git push";
    py = "python3";
    py310 = "python3.10";
    n-u = "nix run github:nix-community/home-manager -- switch --impure -b backup --flake ~/nix#local";
    os-u = "sudo nixos-rebuild switch --impure --flake ~/nix#local";
  };
}