{ pkgs, ...}:
{
  home.packages = with pkgs;[
      tldr
      gemini-cli
      gcc
      caligula
      stdenv.cc.cc.lib
  ];
  imports = [
    "${fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master"}/modules/vscode-server/home.nix"
  ];

  services.vscode-server.enable = true;
}