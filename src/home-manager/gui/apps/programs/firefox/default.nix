{ pkgs, config,... }:
{
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
        # "extensions.pocket.enabled" = false;
        # "dom.security.https_only_mode" = false;
        # "browser.download.panel.shown" = true;
        # "identity.fxaccounts.enabled" = false;
        # "signon.rememberSignons" = false;
        # "browser.theme.toolbar-theme" = 1;

        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.visibility" = "hide-sidebar"; 
        "browser.aboutConfig.showWarning" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
      };
      # userChrome = builtins.readFile ./userChrome.css;
    };
  };
}