
{input, config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/configuration.nix
    ];
  
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ bamboo pinyin];
  };
  services.xserver.xkb.layout = lib.mkForce"us,vn";
  services.xserver.enable = true;
  services.xserver.displayManager.sessionPackages = [
    pkgs.sway
  ];
   environment.sessionVariables = {
    GTK_IM_MODULE = "ibus";
    QT_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
  };
  # services.xserver = {
  #   # enable = true;
  #   # displayManager.sessionPackages = [
  #   #   pkgs.sway
  #   # ];
  #   xkb.layout = "us,vn";
  #   # xkbOptions = "ctrl:nocaps";
  #   xkb = { variant = ""; };
  # };

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "kln";

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];

}