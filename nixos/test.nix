
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/configuration.nix
    ];
  
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  i18n.inputMethod = {
    enabled = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [bamboo];
  };
}