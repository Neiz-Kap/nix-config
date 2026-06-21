{
  description = "Neiz-Kap dotfiles — macOS (Apple Silicon) + Arch Linux";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Patches home-manager app linking so Spotlight/Launchpad finds Nix-installed .app bundles
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative Catppuccin theming for home-manager modules
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, mac-app-util, catppuccin, ... }: {

    # ── macOS (Apple Silicon) ──────────────────────────────────────────────
    darwinConfigurations."macos" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        mac-app-util.darwinModules.default
        ./darwin/default.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.oneivan = import ./home/default.nix;
          home-manager.sharedModules = [
            catppuccin.homeModules.catppuccin
            mac-app-util.homeManagerModules.default
          ];
        }
      ];
    };

    # ── Arch Linux — standalone home-manager (not NixOS) ──────────────────
    homeConfigurations."oneivan@arch" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        catppuccin.homeManagerModules.catppuccin
        ./linux/default.nix
      ];
    };
  };
}
