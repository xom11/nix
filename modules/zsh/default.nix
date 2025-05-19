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
    historySubstringSearch.enable = true;
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
        "thefuck"
      ];
    };
    plugins = [
      # {
      #   name = "fzf-tab";
      #   src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      # }
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
    ];
    dirHashes = {
      # cd ~cfg
      cfg = "$HOME/.config";
    };

    sessionVariables = {
      NIX_CONFIG="extra-experimental-features = nix-command flakes";
      NIXPKGS_ALLOW_UNFREE = 1;

    };
    initContent = ''
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }

      t() {
        if [ -z "$TMUX" ]; then
          tmux attach -t "$1" || tmux new -s "$1"
        else
          tmux new-window -n "$1"
        fi
      }
      
      
      '';
  }; 
  
}