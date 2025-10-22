{...}:
{
  imports = [
    ../../nix-darwin
  ];
  # Enable darwin-specific settings
  power.sleep = {
    computer = "never";
  }; 
}