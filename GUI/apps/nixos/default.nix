{ pkgs, config,... }:

{
  home.packages = with pkgs; [
    bitwarden-desktop
    qutebrowser
    discord
    vscode
    telegram-desktop
    localsend
    slack
    brave
    google-chrome
    kitty
    # chromedriver
    caprine
    # notion-app-enhanced


  ];
  services.flatpak.packages = [
    # { appId = "com.simplenote.Simplenote"; origin = "flathub"; }
  ];
  programs.firefox = {
    enable = true;
    profiles.default = {
      search.engines = {
        "Nix Packages" = {
          urls = [{
            template = "https://search.nixos.org/packages";
            params = [
              { name = "type"; value = "packages"; }
              { name = "query"; value = "{searchTerms}"; }
            ];
          }];

          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@np" ];
        };
      };
      search.force = true;

      settings = {
        "extensions.pocket.enabled" = false;
        "dom.security.https_only_mode" = false;
        "browser.download.panel.shown" = true;
        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;
        "browser.theme.toolbar-theme" = 1;
      };
      userChrome = builtins.readFile ./userChrome.css;
    };
  };
}
