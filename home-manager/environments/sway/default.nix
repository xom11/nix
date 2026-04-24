{
  config,
  pkgs,
  lib,
  getPath,
  mkModule,
  ...
}:
let
  pwd = getPath ./.;
  # Packages that need system integration (GPU/DRM, PAM, logind)
  # must be installed via apt instead of Nix on non-NixOS systems
  aptPackages = [
    "sway"
    "swaylock"
    "xdg-desktop-portal-wlr"
  ];
in
mkModule config ./. {
  home.file = {
    ".config/sway" = {
      source = config.lib.file.mkOutOfStoreSymlink "${pwd}";
    };
    ".config/kanshi/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${pwd}/kanshi.conf";
    };
  };
  xdg.configFile."environment.d/999-nix-path.conf".text = ''
    PATH=${config.home.homeDirectory}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH
  '';
  home.activation.aptPackages = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v apt-get &>/dev/null; then
      missing=()
      for pkg in ${lib.concatStringsSep " " aptPackages}; do
        if ! dpkg -s "$pkg" &>/dev/null; then
          missing+=("$pkg")
        fi
      done
      if [ ''${#missing[@]} -gt 0 ]; then
        echo "Installing apt packages: ''${missing[*]}"
        sudo apt-get install -y "''${missing[@]}"
      fi
    fi
  '';
  home.packages = with pkgs; [
    libnotify
    mako
    wl-clipboard
    brightnessctl
    rofi
    grim
    slurp
    swaybg
    swayidle
    autotiling
    bluetui
    wtype
    cliphist
    kanshi
    jq
  ];
}
