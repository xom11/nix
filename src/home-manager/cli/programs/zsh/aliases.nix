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
    lzg = "lazygit";
    lzd = "lazydocker";
    py = "python";
    m = "micromamba";
  };
}