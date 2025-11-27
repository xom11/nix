{
  pkgs,
  ...
}: let
  fcitx5-macos = pkgs.callPackage ./fcitx5-macos/package.nix {};
  raiseorlaunch = pkgs.callPackage ./raiseorlaunch/package.nix {};
in {
  home.packages = [
    fcitx5-macos
  ];
}

