{
  description = "Home Manager configuration";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
    allowUnfree = true;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.kln = nixpkgs.lib.nixosSystem {
      modules = [ ./nixos/configuration.nix ];
    };
    nixosConfigurations.local = nixpkgs.lib.nixosSystem {
      modules = [ ./nixos/test.nix ];
    };
    homeConfigurations = {
      "server" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home/server.nix ];
      };
      "local" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home.nix ];
      };
    };
  };
}