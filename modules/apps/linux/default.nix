{ config, lib, pkgs, nixgl, ... }:

{
  nixGL.packages = import nixgl { inherit pkgs; };
  nixGL.defaultWrapper = "mesa";
  nixGL.installScripts = [ "mesa" ];

  # targets.genericLinux.enable = true;
  # xdg.mime.enable = true;
  # xdg.systemDirs.data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];

  home.packages = with pkgs; [
    (config.lib.nixGL.wrap kitty)
    # (config.lib.nixGL.wrap brave)
    # (config.lib.nixGL.wrap vscode)
    preload
    bitwarden-desktop
    discord
    vscode
    telegram-desktop
    localsend
    joplin-desktop
    slack
    thunderbird
    google-chrome
    # chromedriver
    caprine

  ];
  home.activation = {
    linkDesktopApplications = {
      after = [ "writeBoundary" "createXdgUserDirectories" ];
      before = [ ];
      data = ''
        mkdir -p ${config.home.homeDirectory}/.local/share/icons/nix-icons
        ln -sf ${config.home.homeDirectory}/.nix-profile/share/icons ${config.home.homeDirectory}/.local/share/icons/nix-icons

        mkdir -p ${config.home.homeDirectory}/.local/share/applications
        for file in ${config.home.homeDirectory}/.nix-profile/share/applications/*; do
            if [ -f "$file" ]; then
                ln -sf "$file" ${config.home.homeDirectory}/.local/share/applications/
            fi
        done

        mkdir -p ${config.home.homeDirectory}/.local/share/gnome-shell
        ln -sf ${config.home.homeDirectory}/.nix-profile/share/gnome-shell/extensions ${config.home.homeDirectory}/.local/share/gnome-shell/

        ${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.home.homeDirectory}/.local/share/applications
      '';
    };
  };
}