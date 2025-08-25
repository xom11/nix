{ config, pkgs, lib, ... }:

  # Import your custom package
  let
    raiseorlaunch = pkgs.callPackage ./raiseorlaunch.nix { };
  in
{

  home.packages = [
    raiseorlaunch # Add your package here!
  ];
  
}