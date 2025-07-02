{pkgs, ...}:
{
  home.packages = with pkgs;
    [ 
      nerd-fonts.dejavu-sans-mono
      fira-code
      fira-code-symbols
      meslo-lgs-nf
    ];

  fonts.fontconfig.enable = true;

}