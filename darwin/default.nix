{ config, pkgs, ... }:
{
  imports = [
    ./homebrew.nix
    ./system-preferences.nix
  ];

  system.primaryUser = "oneivan";

  networking.hostName = "macos";
  networking.computerName = "Neiz-Kap's Mac";

  # nix-darwin manages the nix daemon unconditionally; no explicit enable needed
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "root" "oneivan" ];
    max-jobs = "auto";
    cores = 0;
  };

  nixpkgs.config.allowUnfree = true;

  # knownUsers is required for nix-darwin to actually apply shell/user changes
  # to existing macOS accounts via dscl
  users.knownUsers = [ "oneivan" ];
  users.users.oneivan = {
    name = "oneivan";
    home = "/Users/oneivan";
    shell = pkgs.fish;
    uid  = 501;
  };

  # Fish must be registered as a valid login shell on macOS
  environment.shells = [ pkgs.fish ];
  programs.fish.enable = true;

  # Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # System-wide fonts (available in Font Book and all apps)
  fonts.packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    font-awesome
    noto-fonts
    noto-fonts-cjk-sans
  ];

  system.stateVersion = 5;
}
