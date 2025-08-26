{ config, pkgs, lib, device,... }:

  let
    raiseorlaunch = pkgs.callPackage ./raiseorlaunch.nix { };
  in
{

  home.packages = [

  ]++(lib.optionals (device == "x1g6" ) [
    raiseorlaunch 

  ]);
  
}