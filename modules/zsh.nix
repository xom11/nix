{config, pkgs, ... }:
{
  home.packages = with pkgs; [
    zsh
    oh-my-zsh
    zsh-autosuggestions
    zsh-completions
    zsh-history-substring-search
    zsh-syntax-highlighting
    zsh-vi-mode
  ];
  programs.zsh = {
    enable = true;
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
    initContent = ''
      export PATH=/run/wrappers/bin:$PATH
      # Make Vi mode transitions smoother
      export KEYTIMEOUT=1

      autoload -Uz compinitcompinit

      ZSH_THEME='robbyrussell'

      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }
      
      
      '';
  }; 
  
}