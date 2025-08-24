{pkgs, lib, device, ...}:
lib.mkIf (device != "server") ( 
{
  home.packages = with pkgs;
    [ 
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.fira-code
      nerd-fonts.meslo-lg
    ];

  fonts.fontconfig.enable = true;

}