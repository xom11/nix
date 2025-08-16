{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nixgl.url = "github:nix-community/nixGL";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
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

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    system-manager.url = "github:numtide/system-manager";
    system-manager.inputs.nixpkgs.follows = "nixpkgs";

    ibus-bamboo.url = "github:BambooEngine/ibus-bamboo";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    { ... }@inputs:
    with inputs;
    let
      system = builtins.currentSystem;
      username =
        if builtins.getEnv "SUDO_USER" != "" then
          builtins.getEnv "SUDO_USER"
        else if builtins.getEnv "USER" != "" then
          builtins.getEnv "USER"
        else
          "kln";
      homeDir =
        if builtins.match ".*-darwin" system != null then "/Users/${username}" else "/home/${username}";

      dotfileDir = "${homeDir}/.nix/src/home-manager/gui/dotfiles";

      specialArgs = inputs // {
        inherit
          username
          dotfileDir
          system
          homeDir
          sudo_user
          user
          ;
      };

    in
    {
      darwinConfigurations = {
        "macmini" = nix-darwin.lib.darwinSystem {
          specialArgs = specialArgs // {
            device = "macmini";
            distro = "macos";
          };
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
            home-manager.darwinModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${username}.imports = [
                nixvim.homeModules.nixvim
                agenix.homeManagerModules.default
                ./hosts/macmini/home.nix
              ];
            }
          ];
        };
        "macbook" = nix-darwin.lib.darwinSystem {
          inherit specialArgs;
          system = system;
          modules = [
            ./hosts/macbook/configuration.nix
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
            home-manager.darwinModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${username}.imports = [
                ./hosts/macbook/home.nix
              ];
            }
          ];
        };
      };
      nixosConfigurations = {
        "x1g6" = nixpkgs.lib.nixosSystem {
          specialArgs = specialArgs // {
            distro = "nixos";
            device = "x1g6";
          };
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
                # agenix.homeManagerModules.default
                nixvim.homeModules.nixvim
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
            nixvim.homeModules.nixvim
          ];
        };
        "minimal" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./hosts/minimal/home.nix
          ];
        };
        "desktop" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = specialArgs;
          modules = [
            nixvim.homeModules.nixvim
            ./hosts/desktop/home.nix
          ];
        };
      };
      systemConfigs = {
        "desktop" = system-manager.lib.makeSystemConfig {
          extraSpecialArgs = specialArgs // {
            distro = "ubuntu";
          };
          modules = [
            ./hosts/desktop/configuration.nix
          ];
        };
      };
    };
}
