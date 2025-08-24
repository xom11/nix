{ pkgs, ... }:
{
  home.packages = with pkgs; [
    caligula
  ];
}