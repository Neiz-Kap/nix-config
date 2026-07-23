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

    taps = [ ];

    # GUI apps as .app bundles — NOT installed via Nix (macOS integration, GPU drivers, auto-updates)
    casks = [
      # Terminal
      "kitty"
      "tabby"

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
