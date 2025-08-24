{ pkgs, device, lib, ... }:
lib.mkIf (device == "x1g6") {
  home.packages = with pkgs;[
      tldr
      gemini-cli
      gcc
      caligula
      feh
      picom
  ];
  imports = [
    "${fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master"}/modules/vscode-server/home.nix"
  ];

  services.vscode-server.enable = true;
}