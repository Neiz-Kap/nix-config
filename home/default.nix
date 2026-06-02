{ config, pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux  = pkgs.stdenv.isLinux;
in
{
  imports = [
    ./packages.nix
    ./fish.nix
    ./git.nix
    ./neovim.nix
    ./kitty.nix
    ./starship.nix
    ./tmux.nix
    ./fonts.nix
  ];

  home.username = "oneivan";
  home.homeDirectory = if isDarwin then "/Users/oneivan" else "/home/oneivan";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR     = "nvim";
    VISUAL     = "nvim";
    PAGER      = "less";
    VOLTA_HOME = "${config.home.homeDirectory}/.volta";
  };

  # XDG base directories
  xdg.enable = true;
  xdg.configHome = "${config.home.homeDirectory}/.config";

  home.stateVersion = "24.11";
}
