{ config, pkgs, lib, ... }:
{
  imports = [
    ../home/default.nix
  ];

  # Hyprland, SDDM, and system packages stay managed by pacman.
  # This module extends home/default.nix with Linux-specific overrides.

  # SSH selector script (used in .gitconfig sshCommand — Linux only)
  home.sessionVariables.GIT_SSH_COMMAND = "${config.home.homeDirectory}/.local/bin/git-ssh-selector";

  # Zed editor config symlink (installed via pacman or AUR on Arch)
  xdg.configFile."zed".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.dotfiles/.config/zed";

  # AGS widget toolkit config (Linux/Hyprland only)
  xdg.configFile."ags".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.dotfiles/.config/ags";
}
