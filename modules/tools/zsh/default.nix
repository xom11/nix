{config, pkgs, ... }:
{
  imports = [
    ./aliases.nix
  ];

  home.packages = with pkgs; [
  ];

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # historySubstringSearch.enable = true;
    history = {
      ignoreDups = true;
      ignoreAllDups = true;
      save = 1000000;
      size = 1000000;
    };
    oh-my-zsh = {
      enable = true;
      # theme = "robbyrussell";
      plugins = [
        "git"
        "extract"
        "copyfile"
        "copypath"
        "fzf"
        "z"
        "uv"
        "tmux"
        "sudo"
      ];
    };
    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
      {
        name = "zsh-vi-mode";
        src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
      }
      {
        name = "powerlevel10k";
        src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
        file = "powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ./p10k-config;
        file = "p10k.zsh";
      }
      {
        name = "zshrc";
        src = ./zshrc;
        file = "init.zsh";
      }
    ];
    dirHashes = {
      # cd ~cfg
      cfg = "$HOME/.config";
      nix = "$HOME/nix";
    };

    sessionVariables = {
      NIX_CONFIG="extra-experimental-features = nix-command flakes";
      NIXPKGS_ALLOW_UNFREE = 1;
    };
    initContent = builtins.readFile ./.zshrc;
  }; 
  
}