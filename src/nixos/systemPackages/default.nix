{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    python313
    python311
    python310
  ];
}
