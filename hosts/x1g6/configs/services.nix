{pkgs, username, ...}:
{
  virtualisation.docker.enable = true;
  users.users.${username}.extraGroups = [ "docker" ];

  services.tailscale.enable = true;
  services.openssh.enable = true;

  # i18n.inputMethod = {
  #   enable = true;
  #   type = "ibus";
  #   ibus.engines = with pkgs.ibus-engines; [bamboo];
  # };

services.keyd = {
  enable = true;
  keyboards = {
    default = {
      ids = [ "*" ]; # what goes into the [id] section, here we select all keyboards
      # Everything but the ID section:
      settings = {
        main = {
          capslock = "overload(hyper, esc)";
        };
        otherlayer = {};
      };
      extraConfig = ''
        [hyper:C-M-A]
      '';
    };
  };
};

  # Optional, but makes sure that when you type the make palm rejection work with keyd
  # https://github.com/rvaiya/keyd/issues/723
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';
}