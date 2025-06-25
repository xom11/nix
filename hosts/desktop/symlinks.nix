{ pkgs, lib, config, ... }:
{
  home.activation = {
    linkDesktopApplications = {
      after = [ "writeBoundary" "createXdgUserDirectories" ];
      before = [ ];
      data = ''


        ln -sf ${config.home.homeDirectory}/.nix-profile/share/gnome-shell/extensions ${config.home.homeDirectory}/.local/share/gnome-shell/
        ln -sf ${config.home.homeDirectory}/.nix-profile/bin ${config.home.homeDirectory}/.local
        ln -sf ${config.home.homeDirectory}/.nix-profile/share/applications ${config.home.homeDirectory}/.local/share

        ${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.home.homeDirectory}/.local/share/applications
      '';
    };
  };
}