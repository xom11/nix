{ pkgs, ... }:
{
  home.packages = with pkgs; [
    myapp
  ];
}