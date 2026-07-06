{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # Shell utilities
    fzf
    ripgrep
    bat
    eza
    fd
    jq
    yq-go
    htop
    btop
    fastfetch
    curl
    wget
    httpie
    imagemagick
    ffmpeg
    gnupg
    tree
    unzip
    p7zip
    ncdu
    tldr
    delta        # Better git diff pager

    # Git extras
    gh
    git-lfs

    # Build tools
    just

    # Dev languages
    go
    rustup       # Manages cargo, rustfmt, clippy — do NOT also add cargo here
    python313
    # Node: managed by Volta (volta binary is declared below)
    volta

    # Containers
    docker          # CLI
    docker-compose
    colima          # lightweight VM runtime (replaces Docker Desktop on macOS)

    # Nix tooling
    nixpkgs-fmt
    nil

    # AI coding assistants
    claude-code
    opencode

    # LSP servers and formatters for LazyVim/neovim
    lua-language-server
    typescript-language-server
    vscode-langservers-extracted
    stylua
    prettierd
    ruff
    black
    gnumake
    pkgconf  # pkg-config replacement; Apple's cc comes from CLT, not Nix GCC

  ] ++ lib.optionals pkgs.stdenv.isLinux [
    xdg-utils
    wl-clipboard
    xclip
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    mas    # Mac App Store CLI
  ];
}
