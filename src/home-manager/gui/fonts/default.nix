{pkgs, ...}:
{
  home.packages = with pkgs;
    [ 
      nerd-fonts.dejavu-sans-mono
      # fira-code
      # fira-code-symbols
      # meslo-lgs-nf
      nerd-fonts.meslo-lg
    ];

  fonts.fontconfig.enable = true;

}