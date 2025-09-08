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

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    { ... }@inputs:
    with inputs;
    let
      system = builtins.currentSystem;
      username =
        let
          checkUser = user: user != "" && user != "root" && user != "nixos";
          sudoUser = builtins.getEnv "SUDO_USER";
          normalUser = builtins.getEnv "USER";
        in
        if checkUser sudoUser then
          sudoUser
        else if checkUser normalUser then
          normalUser
        else
          "kln";
      homeDir =
        if builtins.match ".*-darwin" system != null then "/Users/${username}" else "/home/${username}";

      dotfileDir = "${homeDir}/.nix/home-manager/dotfiles";
      device = "";

      args = inputs // {
        inherit
          username
          dotfileDir
          system
          homeDir
          device
          ;
      };

    in
    {
      darwinConfigurations = {
        "macmini" =
          let
            specialArgs = args // {
              device = "macmini";
            };
          in
          nix-darwin.lib.darwinSystem {
            specialArgs = specialArgs;
            system = system;
            modules = [
              ./nix-darwin
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
      };
      nixosConfigurations = {
        "x1g6" =
          let
            specialArgs = args // {
              device = "x1g6";
            };
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = specialArgs;
            system = system;
            modules = [
              nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
              disko.nixosModules.disko
              /etc/nixos/hardware-configuration.nix
              ./nixos
              home-manager.nixosModules.home-manager
              {
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = specialArgs;
                home-manager.users.${username}.imports = [
                  nix-flatpak.homeManagerModules.nix-flatpak
                  agenix.homeManagerModules.default
                  nixvim.homeModules.nixvim
                  ./home-manager
                ];
              }
            ];
          };
        "test" =
          let
            specialArgs = args // {
              device = "test";
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = system;
            modules = [
              /etc/nixos/hardware-configuration.nix
              disko.nixosModules.disko
              ./disko/disko-config.nix
              ./nixos
              home-manager.nixosModules.home-manager
              {
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = specialArgs;
                home-manager.users.${username}.imports = [
                  nix-flatpak.homeManagerModules.nix-flatpak
                  ./home-manager/base
                ];
              }
            ];
          };
      };
      homeConfigurations = {
        "server" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = args // {
            device = "server";
          };
          modules = [
            ./home-manager
            nixvim.homeModules.nixvim
            agenix.homeManagerModules.default
          ];
        };
        "desktop" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = args // {
            device = "desktop";
          };
          modules = [
            nixvim.homeModules.nixvim
            agenix.homeManagerModules.default
            ./home-manager
          ];
        };
      };
      systemConfigs = {
        "desktop" = system-manager.lib.makeSystemConfig {
          extraSpecialArgs = specialArgs // {
            device = "desktop";
          };
          modules = [
            ./system-manager
          ];
        };
      };
    };
}
