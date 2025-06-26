{config, pkgs, ...}:
{
  programs.ssh = {
    enable = true;
    extraConfig = builtins.readFile ./config;
    hostKeyAlgorithms = [
      "ssh-ed25519"
    ];
    matchBlocks = {
      "john.example.com" = {
        hostname = "example.com";
        user = "john";
      };
    };
  };
}