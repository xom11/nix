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
    # home brew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs = {self, nix-darwin, nixpkgs, home-manager, ... }@inputs: {
    darwinConfigurations.macos = nix-darwin.lib.darwinSystem {
      # system = "aarch64-darwin";
      modules = [
        ./hosts/darwin/configuration.nix
      ];
    };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      # system = "x86_64-linux";
      modules = [ 
        ./hosts/nixos/configuration.nix 
      ];
    };
    homeConfigurations = {
      "macos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./hosts/darwin/home.nix ];
      };
      "nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./hosts/nixos/home.nix ];
      };
    };
  };
}