{config, pkgs, ... }:
{
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
      save = 1000000;
      size = 1000000;
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "vi-mode"
        "sudo"
        "web-search"
        "extract"
        "copyfile"
        "copypath"
        "fzf"
        "z"
        "uv"
      ];
    };

    shellAliases = {
      v="nvim";
      vcf="cd ~/.config/nvim && nvim";
      vz="nvim ~/.zshrc";
      sz="source ~/.zshrc";
      spy="source .venv/bin/activate";
      gcg-kln="git config --global user.name khanhkhanhlele && git config --global user.email namkhanh20xx@gmail.com";
      gcl-kln="git config --local user.name khanhkhanhlele && git config --local user.email namkhanh20xx@gmail.com";
      gu="git pull && git add . && git commit -m 'update' && git push";
      py="python3";
      py310="python3.10";
      nix-u="nix run github:nix-community/home-manager -- switch --impure --flake ~/nix#local";
      os-u="sudo nixos-rebuild switch --impure --flake ~/nix#local";
      cat="bat --paging=never --plain";
      fp="fzf --preview='bat --color=always {}'";
      vf="nvim $(fzf -m --preview='bat --color=always {}')";
      ls="eza --icons --group-directories-first";
    };
    sessionVariables = {
      KEYTIMEOUT=1;

    };
    initContent = ''
      # Make Vi mode transitions smoother

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