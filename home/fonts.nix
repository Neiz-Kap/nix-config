{ pkgs, lib, ... }:
{
  # On macOS, fonts are declared in darwin/default.nix via fonts.packages (system-wide).
  # On Linux (non-NixOS), home-manager installs fonts to ~/.local/share/fonts/.
  home.packages = lib.mkIf pkgs.stdenv.isLinux (with pkgs; [
    fira-code
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    font-awesome
    noto-fonts
    noto-fonts-cjk-sans
  ]);
}
