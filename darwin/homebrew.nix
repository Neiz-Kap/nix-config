{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # "zap" removes anything not declared here — comment out if you want manual installs to persist
      cleanup = "zap";
    };

    taps = [
      # Required for the termic cask (not in homebrew/cask). `trusted = true` adds
      # `trusted: true` to this tap's Brewfile line, so `brew bundle` marks it trusted
      # as part of the same run instead of relying on a prior interactive `brew trust`
      # (which is keyed to a $HOME that root-context activation doesn't see).
      { name = "simion/termic"; trusted = true; }
    ];

    # GUI apps as .app bundles — NOT installed via Nix (macOS integration, GPU drivers, auto-updates)
    casks = [
      # Terminal
      "kitty"
      "tabby"
      "termic"

      # Editors
      "vscodium"
      "zed"
      "cursor"

      # Notes & productivity
      "obsidian"
      "onlyoffice"

      # Security
      "bitwarden"

      # Databases
      "tableplus"

      # API testing
      "bruno"
      "postman"

      # Communication
      "telegram"

      # Media
      "vlc"
      "obs"

      # Remote desktop
      "windows-app"  # RDP client for Windows/Azure VMs (rebrand of Microsoft Remote Desktop)

      # Networking
      "happ"  # proxy client (V2Ray/Xray-based)

      # File managers
      "marta"      # keyboard-driven dual-pane file manager
      "forklift"   # dual-pane file manager + SFTP/S3/WebDAV client

      # System utilities
      "raycast"             # Spotlight replacement with extensions
      "karabiner-elements"  # Key remapping
      "paseo"               # Polkadot/Substrate wallet

      # Browsers (choose what you use; zen-browser also available via nix)
      # "arc"
      # "firefox"
    ];

    # Mac App Store apps — requires being signed in to App Store first
    # Find IDs with: mas search <app name>
    masApps = {
      # "Amphetamine" = 937984704;
    };
  };
}
