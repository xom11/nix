{ pkgs, ...}:
{
  home.packages = with pkgs;[
      tldr
      gemini-cli
      gcc
  ];
}