
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
    google-chrome

  ];
  home.file = {
  ".zshrc".source = ./dotfiles/zsh/.zshrc;
  ".config/atuin".source = ./dotfiles/atuin;
  ".config/kitty".source = ./dotfiles/kitty;
  ".config/run-or-raise".source = ./dotfiles/run-or-raise;
  ".config/tmux".source = ./dotfiles/tmux;
};

  home.sessionPath = [
    "/run/current-system/sw/bin"
      "$HOME/.nix-profile/bin"
  ];

  programs.home-manager.enable = true;
  # zsh
  programs.zsh =  {
    enable = true;
    oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "zsh-autosuggestions"
          "zsh-completions"
          "history-substring-search"
          "zsh-syntax-highlighting"
        ];
      };
  };

  # git 
  programs.git.enable = true;
  programs.git.userName = "khanhkhanhlele";
  programs.git.userEmail = "namkhanh20xx@gmail.com";
  nixpkgs.config.allowUnfree = true;

  # Bật Flatpak
  programs.flatpak.enable = true;

  # Thêm repo Flathub
  # services.flatpak.remotes = [
  #   {
  #     name = "flathub";
  #     location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  #   }
  # ];

  # Cài ứng dụng Flatpak (tùy chọn)
  # services.flatpak.packages = [
  #   "com.spotify.Client"
  #   "org.telegram.desktop"
  # ];
}

