{config, pkgs, ... }:
{
  imports = [
    ./aliases.nix
  ];

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
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
        # "tmux"
        "sudo"
      ];
    };
    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
      # {
      #   name = "zsh-vi-mode";
      #   src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
      # }
      {
        name = "powerlevel10k";
        src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
        file = "powerlevel10k.zsh-theme";
      }
      {
        name = "p10k";
        src = ./p10k;
        file = "p10k.zsh";
      }
      {
        name = "func";
        src = ./func;
        file = "func.zsh";
      }
      {
        name = "py";
        src = ./py;
        file = "py.zsh";
      }
    ];
    dirHashes = {
      # cd ~cfg
      cfg = "$HOME/.config";
      nix = "$HOME/.nix";
      dev = "$HOME/Documents/dev";
      note = "$HOME/Documents/note";
      test = "$HOME/Documents/test";
    };

    sessionVariables = {
      NIX_CONFIG="extra-experimental-features = nix-command flakes";
      NIXPKGS_ALLOW_UNFREE = 1;
    };
    initContent = ''
      zvm_after_init() {
        source ${config.programs.fzf.package}/share/fzf/key-bindings.zsh
      }      
      printf '\e[5 q'
    '';
  }; 
  
}
