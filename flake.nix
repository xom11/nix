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
      system = "aarch64-darwin";
      # system.stateVersion = "24.11";
      modules = [ ./macos/configuration.nix ];
      specialArgs = { inherit inputs; };
    };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [ 
        ./nixos/configuration.nix 
        ];
    };
    homeConfigurations = {
      "nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home.nix ];
      };
      "macos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./home-mac.nix ];
      };
    };
  };
}