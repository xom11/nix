
{config, lib, ...}:
let
  cfg = config.services.keyd;
in  
{
  options.services.keyd = {
    enable = lib.mkEnableOption "Enable keyd service";
  };
  config = lib.mkIf cfg.enable {
    services.keyd = {
      enable = true;
      keyboards = {
        default = {
          ids = [ "*" ];
          # settings = {
          #   main = {
          #   };
          #   otherlayer = {};
          # };
          extraConfig = builtins.readFile ./keyd.nix.conf;
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
  };
}
