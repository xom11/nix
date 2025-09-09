{ inputs, outputs, args, ... }:
{
  mkDarwin = { device,}:
  let
    specialArgs = args // {
      device = device;
    };
  in
  inputs.nix-darwin.lib.darwinSystem {
    specialArgs = specialArgs;
    system = args.system;
    modules = [
      ./hosts/macmini/configuration.nix
      inputs.nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          enable = true;
          enableRosetta = true;
          autoMigrate = true;
          mutableTaps = true;
          user = args.username;
        };
      }
      inputs.home-manager.darwinModules.home-manager
      {
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = specialArgs;
        home-manager.users.${args.username}.imports = [
          inputs.nixvim.homeModules.nixvim
          inputs.agenix.homeManagerModules.default
          ./hosts/macmini/home.nix
        ];
      }
    ];
  };
}