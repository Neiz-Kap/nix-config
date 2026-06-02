{ config, pkgs, ... }:
{
  programs.neovim = {
    enable        = true;
    defaultEditor = true;
    viAlias       = true;
    vimAlias      = true;
    # No plugins here — LazyVim manages them via lazy.nvim bootstrap
  };

  # Symlink to the stow-managed LazyVim config outside the Nix store.
  # mkOutOfStoreSymlink is required because LazyVim writes lazy-lock.json at runtime
  # and the Nix store is read-only.
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.dotfiles/.config/nvim";
}
