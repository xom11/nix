{input, config, pkgs, lib, username, ... }:
let
  bamboo = pkgs.callPackage ./ibus-bamboo.nix {};
in
{
  config = {
    nixpkgs.hostPlatform = "x86_64-linux";
  };
  imports =
    [ # Include the results of the hardware scan.
    ];
  
  # programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  





}