{input, config, pkgs, lib, username, ... }:
let
  bamboo = pkgs.callPackage ./ibus-bamboo.nix {};
in
{
  imports =
    [ # Include the results of the hardware scan.
    ];
  
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;


  };



}