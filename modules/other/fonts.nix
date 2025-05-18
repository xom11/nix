{pkgs, config, options, ...}:
{
  # home.packages = with pkgs; [
  #   # meslo-lgs-nf
  #   # noto-fonts
  #   # noto-fonts-emoji
  #   fira-code
  #   fira-code-symbols
  #   # nerd-fonts.jetbrains-mono
  # ];
  fonts.packages = with pkgs; [
  noto-fonts
  noto-fonts-cjk-sans
  noto-fonts-emoji
  liberation_ttf
  fira-code
  fira-code-symbols
  mplus-outline-fonts.githubRelease
  dina-font
  proggyfonts
];
}