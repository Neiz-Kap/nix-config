{ config, pkgs, ... }:
{
  programs.neovim = {
    enable        = true;
    defaultEditor = true;
    viAlias       = true;
    vimAlias      = true;
    withRuby      = false;
    withPython3   = false;
    # No plugins here — LazyVim manages them via lazy.nvim bootstrap
  };

  # nvim config symlink is managed separately — uncomment once dotfiles are in place at
  # ~/.dotfiles/.config/nvim (mkOutOfStoreSymlink keeps lazy-lock.json writable)
  # xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
  #   "${config.home.homeDirectory}/.dotfiles/.config/nvim";
}
