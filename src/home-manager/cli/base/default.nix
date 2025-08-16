{agenix, system, ...}:
{
  home.packages = [
    agenix.packages.${system}.default
  ];

} 