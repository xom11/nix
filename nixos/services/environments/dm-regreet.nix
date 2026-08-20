{
  config,
  lib,
  getRelPath,
  ...
}: let
  relPath = getRelPath ./.;
  pathList = ["modules"] ++ (lib.splitString "/" relPath);
  cfg = lib.getAttrFromPath pathList config;
in {
  # greetd and ReGreet are TWO things, which is the easy misreading here:
  #   greetd   daemon. PAM auth, starts the session. DRAWS NOTHING.
  #   ReGreet  greeter. The GTK4 UI, running inside `cage`.
  #
  # greetd alone is unusable -- it requires a greeter. That split is the point,
  # unlike GDM/SDDM which fuse both into one unswappable block.
  #
  # nixpkgs' `services.displayManager.regreet` wires it all up, so one `enable`
  # line is enough here.
  config = lib.mkIf (cfg.enable && cfg.displayManager == "regreet") {
    services.displayManager.regreet.enable = true;

    # This is ReGreet's official key for dark mode, and it goes WITH
    # `theme_name = "Adwaita"` rather than replacing it with "Adwaita-dark":
    # GTK4 picks the dark variant itself when the flag is set.
    services.displayManager.regreet.settings.GTK.application_prefer_dark_theme = true;

    # REQUIRED, and a config that lies if forgotten. `nixos/base` enables
    # autoLogin for every NixOS host, but that option is consumed by
    # GDM/SDDM/LightDM -- greetd does NOT read it. Left `true`, eval and rebuild
    # both stay green with no warning, `nix eval` still reports autoLogin = true,
    # and the machine simply does not auto-login.
    #
    # greetd's own mechanism is `initial_session`, deliberately not used: a
    # hardcoded session that breaks drops you straight into the breakage with no
    # chance to pick another -- which has happened on rog.
    services.displayManager.autoLogin.enable = lib.mkForce false;
  };
}
