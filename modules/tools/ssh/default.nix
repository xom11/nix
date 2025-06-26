{config, pkgs, ...}:
{
  programs.ssh = {
    enable = true;
    extraConfig = builtins.readFile ./config;
    matchBlocks = {
      "john.example.com" = {
        hostname = "example.com";
        user = "john";
      };
    };
  };
}