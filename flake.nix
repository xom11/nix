{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
    homebrew-bundle = { url = "github:homebrew/homebrew-bundle"; flake = false; };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = {... }@inputs:
    with inputs;
    let
      username = builtins.getEnv "SUDO_USER"; 
      useremail = "__USEREMAIL__";
      hostname = "__HOSTNAME__";
      system = builtins.currentSystem;

      specialArgs =
        inputs
        // {
          inherit username useremail hostname;
        };
    in
    {
    darwinConfigurations."macmini" = nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      system = system;
      modules = [
        ./hosts/macmini/configuration.nix
        nix-homebrew.darwinModules.nix-homebrew 
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            autoMigrate = true;
            mutableTaps = true;
            user = username;
          };
        }
        home-manager.darwinModules.home-manager {
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${username}.imports = [
            ./hosts/macmini/home.nix
          ];
        }
      ];
    };
    nixosConfigurations = {
      "x1g6" = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = system;
        modules = [ 
          ./hosts/x1g6/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${username}.imports = [ 
              nix-flatpak.homeManagerModules.nix-flatpak
              ./hosts/x1g6/home.nix
            ];
          }
        ];
      };
      "surface" = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = system;
        modules = [
          ./hosts/surface/configuration.nix
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
          # {
          #   microsoft-surface.ipts.enable = true;
          #   microsoft-surface.surface-control.enable = false;
          # }
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${username}.imports = [ 
              nix-flatpak.homeManagerModules.nix-flatpak
              ./hosts/surface/home.nix
            ];
          }
        ];
      };
    };
    homeConfigurations = {
      "server" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./hosts/server/home.nix
        ];
      };
      "desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./hosts/desktop/home.nix
        ];
      };
    };
  };
}