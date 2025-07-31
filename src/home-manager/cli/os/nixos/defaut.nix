{ pkgs, ...}:
{
  home.packages = with pkgs;[
      tldr
      ansible
      gemini-cli
  ];
}