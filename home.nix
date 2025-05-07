
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
    ".config/nvim".source = ./dotfiles/nvim;
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

    # ibus
  xsession.windowManager.bspwm.startupPrograms = [
    "${pkgs.ibus}/bin/ibus restart || ${pkgs.ibus}/bin/ibus-daemon -d -r -x"
  ];

  within.neovim.enable = true;
  within.zsh.enable = true;
  within.alacritty.enable = true;

   # show ui app
  programs.zsh.profileExtra = lib.mkAfter ''
    rm -rf ${config.home.homeDirectory}/.local/share/applications/home-manager
    rm -rf ${config.home.homeDirectory}/.icons/nix-icons
    ls ${config.home.homeDirectory}/.nix-profile/share/applications/*.desktop > ${config.home.homeDirectory}/.cache/current_desktop_files.txt
  '';

  home.activation = {
    linkDesktopApplications = {
      after = [ "writeBoundary" "createXdgUserDirectories" ];
      before = [ ];
      data = ''
        rm -rf ${config.home.homeDirectory}/.local/share/applications/home-manager
        rm -rf ${config.home.homeDirectory}/.icons/nix-icons
        mkdir -p ${config.home.homeDirectory}/.local/share/applications/home-manager
        mkdir -p ${config.home.homeDirectory}/.icons
        ln -sf ${config.home.homeDirectory}/.nix-profile/share/icons ${config.home.homeDirectory}/.icons/nix-icons

        # Check if the cached desktop files list exists
        if [ -f ${config.home.homeDirectory}/.cache/current_desktop_files.txt ]; then
          current_files=$(cat ${config.home.homeDirectory}/.cache/current_desktop_files.txt)
        else
          current_files=""
        fi

        # Symlink new desktop entries
        for desktop_file in ${config.home.homeDirectory}/.nix-profile/share/applications/*.desktop; do
          if ! echo "$current_files" | grep -q "$(basename $desktop_file)"; then
            ln -sf "$desktop_file" ${config.home.homeDirectory}/.local/share/applications/home-manager/$(basename $desktop_file)
          fi
        done

        # Update desktop database
        ${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.home.homeDirectory}/.local/share/applications
      '';
    };
  };
}

