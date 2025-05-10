{ lib, config, pkgs, commands, ... }:
with lib;
let 
    cfg = config.within.zsh;
in
{
  programs.fzf = {
        enable = true;
        enableZshIntegration = true; 
    };


  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    historySubstringSearch.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "zsh-autosuggestions"
        "zsh-completions"
        "zsh-history-substring-search"
        "zsh-syntax-highlighting"
        "zsh-powerlevel10k"
      ];

    };
  }; 
}