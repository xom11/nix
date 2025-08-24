{ pkgs, device, lib, ... }:
lib.mkIf (device == "macmini") {
  home.packages = with pkgs; [
    caligula
  ];
}