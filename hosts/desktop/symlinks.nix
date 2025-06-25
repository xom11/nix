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
        for file in ${config.home.homeDirectory}/.nix-profile/share/applications/*; do
            if [ -f "$file" ]; then
                ln -sf "$file" ${config.home.homeDirectory}/.local/share/applications/
            fi
        done

        ${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.home.homeDirectory}/.local/share/applications
      '';
    };
  };
}