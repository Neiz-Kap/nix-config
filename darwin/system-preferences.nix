{ ... }:
{
  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.2;
      show-recents = false;
      minimize-to-application = true;
      orientation = "bottom";
      tilesize = 48;
      mru-spaces = false;
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = false;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXPreferredViewStyle = "Nlsv";      # List view
      FXDefaultSearchScope = "SCcf";      # Search current folder
      _FXShowPosixPathInTitle = true;
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      "com.apple.swipescrolldirection" = false;
      AppleEnableSwipeNavigateWithScrolls = false;
    };

    loginwindow.GuestEnabled = false;

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };

    screencapture.location = "~/Pictures/Screenshots";
  };

  # Mission Control animation speed (not exposed as a typed option)
  system.activationScripts.extraActivation.text = ''
    defaults write com.apple.dock expose-animation-duration -float 0.1
  '';
}
