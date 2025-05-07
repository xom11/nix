
{ config, pkgs, ... }:

{
  home.username = builtins.getEnv "USER";  
  home.homeDirectory = builtins.getEnv "HOME";  
  home.stateVersion = "23.11"; # Giữ nguyên phiên bản

  # Các gói bạn muốn cài đặt
  home.packages = with pkgs; [
    # Dev
    neovim
    neofetch
    htop
    git
    tmux
    htop
    lazygit
    stow
    zsh
    oh-my-zsh
    zsh-autosuggestions
    zsh-completions
    zsh-history-substring-search
    zsh-syntax-highlighting
    zip
    unzip
    wget
    curl
    tree
    jq
    fzf
    ripgrep
    fd
    bat
    eza
    gcc
    python3
    python3Packages.pip
    python3Packages.pipx
    python3Packages.uv
    nodejs
    nodejs.pkgs.npm
    nodejs.pkgs.yarn
    nodejs.pkgs.nodemon
    nodejs.pkgs.pm2
    yazi
    zoxide
    python312Packages.conda
    atuin
    ncdu
    syncthing 

    # Fonts
    noto-fonts
    noto-fonts-emoji
    fira-code

    # AppImage
    flatpak
    ibus-engines.bamboo
    xdg-desktop-portal 
    xdg-desktop-portal-gtk
    bitwarden
    bitwarden-cli
    discord
    gnome-extension-manager
    vscode
    notion
    microsoft-edge
    telegram-desktop
    brave
  ];
  home.file = {
  ".zshrc".source = ./../dotfiles/zsh/.zshrc;
  # ".config/wezterm".source = ~/dotfiles/wezterm;
  # ".config/skhd".source = ~/dotfiles/skhd;
  # ".config/starship".source = ~/dotfiles/starship;
  # ".config/zellij".source = ~/dotfiles/zellij;
  # ".config/nvim".source = ~/dotfiles/nvim;
  # ".config/nix".source = ~/dotfiles/nix;
  # ".config/nix-darwin".source = ~/dotfiles/nix-darwin;
  # ".config/tmux".source = ~/dotfiles/tmux;
  # ".config/ghostty".source = ~/dotfiles/ghostty;
  # ".config/aerospace".source = ~/dotfiles/aerospace;
  # ".config/sketchybar".source = ~/dotfiles/sketchybar;
  # ".config/nushell".source = ~/dotfiles/nushell;
};

  home.sessionPath = [
    "/run/current-system/sw/bin"
      "$HOME/.nix-profile/bin"
  ];
  programs.home-manager.enable = true;
  programs.zsh =  {
    enable = true;
    oh-my-zsh = {
        enable = true;
        plugins = [ "git", "zsh-autosuggestions", "zsh-completions", "zsh-history-substring-search", "zsh-syntax-highlighting" ];
        
      };

  };

  # git 
  programs.git.enable = true;
  programs.git.userName = "khanhkhanhlele";
  programs.git.userEmail = "namkhanh20xx@gmail.com";
  nixpkgs.config.allowUnfree = true;


}

