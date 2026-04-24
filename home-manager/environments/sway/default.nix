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
