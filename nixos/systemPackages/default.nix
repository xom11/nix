{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    python313
    python312
    python311
    python310
  ];
}
