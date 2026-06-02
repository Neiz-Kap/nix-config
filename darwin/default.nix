{ config, pkgs, ... }:
{
  imports = [
    ./homebrew.nix
    ./system-preferences.nix
  ];

  networking.hostName = "macos";
  networking.computerName = "Neiz-Kap's Mac";

  # Nix daemon + flakes
  services.nix-daemon.enable = true;
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "root" "oneivan" ];
    max-jobs = "auto";
    cores = 0;
  };

  nixpkgs.config.allowUnfree = true;

  users.users.oneivan = {
    name = "oneivan";
    home = "/Users/oneivan";
    shell = pkgs.fish;
  };

  # Fish must be registered as a valid login shell on macOS
  environment.shells = [ pkgs.fish ];
  programs.fish.enable = true;

  # Touch ID for sudo — edits /etc/pam.d/sudo declaratively
  security.pam.enableSudoTouchIdAuth = true;

  # System-wide fonts (available in Font Book and all apps)
  fonts.packages = with pkgs; [
    fira-code
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    font-awesome
    noto-fonts
    noto-fonts-cjk-sans
  ];

  system.stateVersion = 5;
}
