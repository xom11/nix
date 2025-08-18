{pkgs, ...}:
{
  imports = [
    ./firefox
    ./brave
  ];
  programs.gnupg.agent.enable = true;
}
