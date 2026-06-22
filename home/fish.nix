{ config, pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux  = pkgs.stdenv.isLinux;
in
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -g fish_greeting ""

      # Volta (Node version manager)
      set -gx VOLTA_HOME "$HOME/.volta"
      fish_add_path "$VOLTA_HOME/bin"

      # Cargo / Rust
      if test -d "$HOME/.cargo/bin"
        fish_add_path "$HOME/.cargo/bin"
      end

      # Local binaries
      fish_add_path "$HOME/.local/bin"

      # pnpm (managed by Volta, but explicit fallback)
      set -gx PNPM_HOME "$HOME/.local/share/pnpm"
      if not string match -q -- $PNPM_HOME $PATH
        fish_add_path "$PNPM_HOME"
      end

    '' + lib.optionalString isDarwin ''
      # Homebrew on Apple Silicon
      fish_add_path "/opt/homebrew/bin"
      fish_add_path "/opt/homebrew/sbin"

      # Apple CLT must come before the Nix profile so `cc` resolves to Apple
      # clang, not Nix GCC — critical for Rust and native extension builds
      fish_add_path "/Library/Developer/CommandLineTools/usr/bin"

    '' + lib.optionalString isLinux ''
      # GNOME Keyring SSH agent (Wayland / Hyprland)
      if test -S "/run/user/(id -u)/gcr/ssh"
        set -gx SSH_AUTH_SOCK "/run/user/(id -u)/gcr/ssh"
      else if test -S "$XDG_RUNTIME_DIR/gcr/ssh"
        set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/gcr/ssh"
      end

      # Jump directory navigator
      if command -q jump
        jump shell fish | source
      end
    '';

    # Abbreviations expand inline in Fish (preferred over aliases)
    shellAbbrs = {
      # Navigation
      ".."  = "cd ..";
      "..." = "cd ../..";

      # Better defaults (use Nix-installed tools)
      ls   = "eza";
      ll   = "eza -la --git --icons";
      la   = "eza -la --icons";
      lt   = "eza --tree --icons";
      cat  = "bat";
      grep = "rg";
      find = "fd";
      top  = "btop";
      df   = "df -h";

      # Editors
      v   = "nvim";
      vi  = "nvim";
      vim = "nvim";

      # Git
      g   = "git";
      gs  = "git status";
      ga  = "git add";
      gc  = "git commit";
      gca = "git commit --amend";
      gp  = "git push";
      gl  = "git log --oneline --graph --decorate";
      gco = "git checkout";
      gcb = "git checkout -b";
      gd  = "git diff";
      gds = "git diff --staged";
      grh = "git reset --hard";
      gst = "git stash";
      gstp = "git stash pop";

      # Nix / system rebuild
      nrs  = "darwin-rebuild switch --flake ~/.dotfiles/nix#macos";
      hms  = "home-manager switch --flake ~/.dotfiles/nix#oneivan@arch";
      nfu  = "nix flake update ~/.dotfiles/nix";
    };

    functions = {
      mkcd = {
        description = "mkdir + cd in one";
        body = "mkdir -p $argv && cd $argv";
      };

      ff = {
        description = "fuzzy find file with preview";
        body = "fzf --preview 'bat --color=always {}'";
      };
    };
  };
}
