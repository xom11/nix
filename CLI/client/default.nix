
{ pkgs, ...}:
{
  home.packages = with pkgs;[
      tldr
      ansible
      pipx
      gemini-cli
  ];
}