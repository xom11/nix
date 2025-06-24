{ config, pkgs, lib, ... }:
let
  isNixOS = pkgs.system == "x86_64-linux" || pkgs.stdenv.system == "aarch64-linux";
  isUbuntu = !isNixOS;
in
{
  builtins.traceVal "myList" pkgs.system;

#   # imports = lib.optionals isNixOS [
#   #   ./nixos
#   # ] ++ lib.optionals isUbuntu [
#   #   ./ubuntu
#   # ];
# }