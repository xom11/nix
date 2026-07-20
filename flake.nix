{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

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

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    # Without these, agenix drags in its own home-manager and nix-darwin (both
    # pinned months back) purely to run its own checks.
    agenix.inputs.home-manager.follows = "home-manager";
    agenix.inputs.darwin.follows = "nix-darwin";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    beckon.url = "github:xom11/beckon";
    beckon.inputs.nixpkgs.follows = "nixpkgs";

    dotbrowser.url = "github:xom11/dotbrowser";
    dotbrowser.inputs.nixpkgs.follows = "nixpkgs";

    nix-apt.url = "github:xom11/nix-apt";

    fcitx5-lotus = {
      url = "github:LotusInputMethod/fcitx5-lotus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    { ... }@inputs:
    let
      # Overlays shipped by flake inputs. Add new tools here — every host
      # (darwin / nixos / standalone HM) picks them up automatically via
      # mkConfigs.nix, so `pkgs.<tool>` is available without per-host
      # wiring. Adding a new tool: declare the input above, then append
      # `inputs.<tool>.overlays.default` to this list.
      flakeOverlays = [
        inputs.beckon.overlays.default
        inputs.dotbrowser.overlays.default
        inputs."fcitx5-lotus".overlays.default
      ];

      lib = import ./lib { inherit inputs flakeOverlays; };

      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs systems;
      pkgsFor = system: inputs.nixpkgs.legacyPackages.${system};

    in
    {
      # Local packages (fcitx5-macos, neofetch2, raiseorlaunch), consumable
      # from outside this flake.
      overlays.default = import ./overlays;

      formatter = forAllSystems (system: (pkgsFor system).alejandra);

      devShells = forAllSystems (system: {
        default = (pkgsFor system).mkShell {
          packages = with pkgsFor system; [ alejandra nixd deadnix statix ];
        };
      });

      darwinConfigurations = {
        macmini = lib.mkDarwin { device = "macmini"; };
        airm3 = lib.mkDarwin { device = "airm3"; };
      };
      nixosConfigurations = {
        x1g6 = lib.mkNixos { device = "x1g6"; };
        vmware = lib.mkNixos { device = "vmware"; };
      };
      homeConfigurations = {
        rog = lib.mkHomeManager { device = "rog"; };
        server = lib.mkHomeManager { device = "server"; };
        desktop = lib.mkHomeManager { device = "desktop"; };
        a14 = lib.mkHomeManager { device = "a14"; };
        minimal = lib.mkHomeManager { device = "minimal"; };
      };
      systemConfigs = inputs.nixpkgs.lib.genAttrs ["aarch64-linux" "x86_64-linux"] (system: {
        desktop = lib.mkSystemManager { device = "desktop"; inherit system; };
        a14 = lib.mkSystemManager { device = "a14"; inherit system; };
      });
    };
  }
