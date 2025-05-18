{pkgs, config, ...}:
{
  home.packages = with pkgs; [
    meslo-lgs-nf
    noto-fonts
    noto-fonts-emoji
    fira-code
    fira-code-symbols
  ];
}