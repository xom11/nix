{config, pkgs, ... }:
{
  imports = [
    ./aliases.nix
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
      save = 1000000;
      size = 1000000;
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "web-search"
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

    sessionVariables = {
      KEYTIMEOUT = 1;
      NIX_CONFIG="extra-experimental-features = nix-command flakes";
      NIXPKGS_ALLOW_UNFREE = 1;

    };
    initContent = ''
      autoload -Uz compinitcompinit


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