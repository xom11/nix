
{ pkgs, ...}:
{
  home.packages = with pkgs;[
      # tldr
      # ansible
      # atuin
      pipx
      # caligula
      gemini-cli
  ];
}