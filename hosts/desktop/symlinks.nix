{ pkgs, lib, config, ... }:
{
  home.activation = {
    linkDesktopApplications = {
      after = [ "writeBoundary" "createXdgUserDirectories" ];
      before = [ ];
      data = ''
        mkdir -p ${config.home.homeDirectory}/.local/share/applications/nix-applications
        mkdir -p ${config.home.homeDirectory}/.local/share/icons/nix-icons
        ln -sf ${config.home.homeDirectory}/.nix-profile/share/icons ${config.home.homeDirectory}/.local/share/icons/nix-icons
        ln -sf ${config.home.homeDirectory}/.nix-profile/share/application ${config.home.homeDirectory}/.local/share/applications/nix-applications

        ${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.home.homeDirectory}/.local/share/applications
      '';
    };
  };
}