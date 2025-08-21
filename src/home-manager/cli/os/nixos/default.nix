{ pkgs, ...}:
{
  home.packages = with pkgs;[
      tldr
      gemini-cli
      gcc
      caligula
      stdenv.cc.cc.lib
  ];
}