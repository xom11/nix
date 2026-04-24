{
  config,
  pkgs,
  getPath,
  mkModule,
  mkApt,
  ...
}:
let
  pwd = getPath ./.;
in
mkModule config ./. {
  home.file = {
    ".config/sway" = {
      source = config.lib.file.mkOutOfStoreSymlink "${pwd}/../sway.d";
    };
    ".config/kanshi/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${pwd}/../kanshi.d/kanshi.conf";
    };
  };
  xdg.configFile."environment.d/999-nix-path.conf".text = ''
    PATH=${config.home.homeDirectory}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH
  '';
  home.activation = mkApt ./. ["sway" "swaylock" "xdg-desktop-portal-wlr"];
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
