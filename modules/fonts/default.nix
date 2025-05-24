{pkgs, lib, config, ...}:
{
  fonts.packages = with pkgs; [
    nerd-fonts.dejavu-sans-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    meslo-lgs-nf
  ];
}