{
  description = "Home Manager configuration";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
    allowUnfree = true;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, nix-darwin, nixpkgs, home-manager, ... }@inputs: {
    darwinConfigurations.macos = nix-darwin.lib.darwinSystem {
      # system = "aarch64-darwin";
      modules = [
        ./nix-darwin/configuration.nix
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.macos = import ./nix-darwin/home.nix; 
        }
      ];
      # home-manager.users.macos = { 
      #   imports = [ ./nix-darwin/home-mac.nix ];
      # };
    };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      # system = "x86_64-linux";
      modules = [ 
        ./nix-os/configuration.nix 
        home-manager.nixosModules.home-manager 
      ];
      home-manager.users.nixos = { 
        imports = [ ./nix-os/home.nix ];
      };
    };
    # homeConfigurations = {
    #   "nixos" = home-manager.lib.homeManagerConfiguration {
    #     pkgs = nixpkgs.legacyPackages.x86_64-linux;
    #     modules = [ ./nix-os/home.nix ];
    #   };
    #   "macos" = home-manager.lib.homeManagerConfiguration {
    #     pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    #     modules = [ ./nix-darwin/home-mac.nix ];
    #   };
    # };
  };
}