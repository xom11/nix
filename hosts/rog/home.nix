{ pkgs, ... }:
{
  # Standalone home-manager on Ubuntu until 2026-08-14; real NixOS since.
  #
  # LD_LIBRARY_PATH is gone with the Ubuntu era, and should stay gone: setting it
  # session-wide leaks into EVERY child, including store binaries that already
  # have the right closure, producing symbol errors that are very hard to trace.
  # Patch a missing library with `programs.nix-ld` or a wrapper instead.
  imports = [
    ../../home-manager
  ];
  modules.home-manager = {
    base = {
      nixos.enable = true;
    };
    dotfiles = {
      ai.enable = true;
      terminal.kitty.enable = true;
      # `rofi-wayland` is now an alias that throws; nixpkgs merged the Wayland
      # fork into `pkgs.rofi` itself. Both Wayland sessions here call rofi from
      # eight places each.
      rofi.enable = true;
    };
    environments = {
      # Since 2026-08-22: DMS owns notifications, lock, idle, wallpaper and
      # monitor profiles in BOTH sway and hyprland here. It regenerates
      # hypr.d/dms/ through the config symlink on every run (gitignored).
      dms.enable = true;
      fonts.enable = true;
      # gnome dropped 2026-08-19 with the GNOME desktop itself: the module only
      # writes dconf keybindings and Shell extensions, so with no GNOME session
      # it still builds and still writes, and nothing reads it.
      hyprland.enable = true;
      i18n.enable = true;
      # Trial since 2026-08-14. Keybindings are niri's DEFAULTS, not ported
      # from sway/hyprland (scrollable-tiling has no counterpart for most of
      # them); the launcher layer is generated into ~/.config/niri-nix/ and
      # included by one line in config.kdl.
      niri.enable = true;
      sway.enable = true;
      wayland.enable = true;
    };
    pkgs = {
      dev.enable = true;
      lang.enable = true;
      tools.enable = true;
      nixos.enable = true;
    };
    programs = {
      # This host's public key is in programs/ssh/authorized_keys, which keys.nix
      # is generated from, so it is an agenix recipient and both .age files were
      # rekeyed for all five.
      #
      # Unlike macOS, the Linux decrypt unit is a systemd oneshot with no
      # `Restart=`, so it does not retry the way launchd does -- run
      # `agenix-reload` by hand if secrets are missing after a first switch.
      agenix.enable = true;
      btop.enable = true;
      git.enable = true;
      herdr.enable = true;
      nvim.enable = true;
      ssh.enable = true;
      tmux.enable = true;
      yazi.enable = true;
      zsh.enable = true;
    };
  };
  home.packages = [
    pkgs.beckon
    pkgs.bws
    # Came from the dotbrave module until it was removed; declared here or the
    # binary leaves PATH and there is no way to apply by hand.
    pkgs.dotbrave
    # Kept from the standalone Ubuntu era.
    pkgs.discordchatexporter-cli
  ];
}
