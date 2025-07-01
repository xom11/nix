{ pkgs, config,... }:

{
  imports = [
    ../share
  ];

  home.packages = with pkgs; [
  ];

}