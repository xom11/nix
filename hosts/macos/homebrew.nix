{...}:
let
  caskApps = [
    "simplenote"
  ];
in
{
  environment.variables = {
    HOMEBREW_NO_ENV_HINTS = "1";
  };
  homebrew = {
    enable = true;
    global.autoUpdate = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # cleanup = "zap";
    };
    taps = [ ];
    brews = [ ];
    casks = caskApps;
  };
}
