{ config, pkgs, lib, ... }:
let
  isNixOS = pkgs.stdenv.system == "x86_64-linux" || pkgs.stdenv.system == "aarch64-linux";
  isUbuntu = !isNixOS;
in
{
  # imports = lib.optionals isNixOS [
  #   ./nixos
  # ] ++ lib.optionals isUbuntu [
  #   ./ubuntu
  # ];
}