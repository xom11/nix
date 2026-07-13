{ pkgs, ... }:
{
  # python310 reached EOL and is gone from nixpkgs-unstable.
  environment.systemPackages = with pkgs; [
    python313
    python312
    python311
  ];
}
