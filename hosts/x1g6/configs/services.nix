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
    # The name is just the name of the configuration file, it does not really matter
    default = {
      ids = [ "*" ]; # what goes into the [id] section, here we select all keyboards
      # Everything but the ID section:
      settings = {
        # The main layer, if you choose to declare it in Nix
        main = {
          capslock = "overload(hyper, esc)"; # you might need to also enclose the key in quotes if it contains non-alphabetical symbols
        };
        otherlayer = {};
      };
      extraConfig = ''
        # put here any extra-config, e.g. you can copy/paste here directly a configuration, just remove the ids part
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