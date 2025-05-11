{config, pkgs, ... }:
{
  home.packages = with pkgs; [
    zsh
    oh-my-zsh
    zsh-autosuggestions
    zsh-completions
    zsh-history-substring-search
    zsh-syntax-highlighting
    zsh-powerlevel10k
  ];
  programs.zsh = {
    enable = true;
    oh-my-zsh.enable = true;
  }; 
  
}