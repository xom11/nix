{ pkgs, config,... }:

{
  imports = [
    ../programs
  ];
  home.packages = with pkgs; [
    zathura
  ];

}