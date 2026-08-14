# AeroSpace — i3-like tiling WM for macOS, replacing the Hyprland/COSMIC
# tiling workflow from Arch. macOS-only: this module is wired into
# home-manager.sharedModules for darwinConfigurations."macos" in flake.nix
# (not imported from home/default.nix), so it never touches the shared
# Linux/Hyprland home-manager config.
#
# Bindings are translated from COSMIC/Hyprland's Super/mainMod, structurally
# (same tiers, same tier-to-tier modifier deltas), onto Ctrl (arrow-based
# tiers) + Option/Alt (letter- and number-based tiers) instead of Cmd:
# https://system76.com/support/articles/pop-cosmic-keyboard-shortcuts
#
# Cmd was tried first and reverted — on macOS, unlike Super on Linux, Cmd is
# not free real estate. Cmd+V/S/G and Cmd+arrows/Cmd+Shift+arrows are Paste,
# Save, Find-Next, and line navigation/selection in essentially every app,
# and binding them globally to AeroSpace silently ate those everywhere.
# Ctrl+arrows was chosen over Option+arrows for the focus/move tiers because
# its only conflict (Mission Control's space-switching/Exposé shortcuts,
# also on Ctrl+arrows) is a one-time System Settings toggle — see MACOS.md —
# whereas Option+arrows collides with word-by-word text navigation, which
# has no toggle and would misfire in every text field, every time.
#
# LIMITATION (deliberate, do not work around): AeroSpace has no
# window/workspace-switch animations. This is a conscious tradeoff for
# speed and reliability, and is part of why AeroSpace doesn't need SIP
# disabled the way yabai does. There is no config knob to fake this.
{ lib, pkgs, ... }:
let
  # Catppuccin Macchiato, matching the palette already used for
  # kitty/tmux/starship elsewhere in this config (see README).
  palette = {
    base = "0xff24273a";
    surface0 = "0xff363a4f";
    surface2 = "0xff5b6078";
    mauve = "0xffc6a0f6";
    text = "0xffcad3f5";
  };

  aerospaceBin = lib.getExe pkgs.aerospace;
  sketchybarBin = lib.getExe pkgs.sketchybar;
  bordersBin = lib.getExe pkgs.jankyborders;

  # Ran by sketchybar's own event system whenever AeroSpace fires
  # `aerospace_workspace_change` (wired below via exec-on-workspace-change).
  workspaceChangedScript = pkgs.writeShellScript "aerospace-workspace-changed" ''
    ${sketchybarBin} --set aerospace.workspace label="$FOCUSED_WORKSPACE"
  '';

  # Minimal sketchybarrc: one item showing the focused AeroSpace workspace.
  # sketchybar looks for this file at $XDG_CONFIG_HOME/sketchybar/sketchybarrc
  # on its own, so it's installed via xdg.configFile below rather than
  # through home-manager's own programs.sketchybar (which would additionally
  # register its own launchd agent — we want AeroSpace's
  # after-startup-command to be the single source of truth for the bar's
  # lifecycle, per the task's autostart requirement).
  sketchybarrc = pkgs.writeShellScript "sketchybarrc" ''
    ${sketchybarBin} --bar height=32 \
                           position=top \
                           padding_left=6 \
                           padding_right=6 \
                           color=${palette.base}

    ${sketchybarBin} --default icon.drawing=off \
                                label.font="SF Pro:Bold:13.0" \
                                label.color=${palette.text} \
                                background.color=${palette.surface0} \
                                background.corner_radius=5 \
                                background.height=24 \
                                background.drawing=on

    ${sketchybarBin} --add item aerospace.workspace left \
                      --set aerospace.workspace \
                            label="$(${aerospaceBin} list-workspaces --focused 2>/dev/null || echo '?')" \
                            script="${workspaceChangedScript}" \
                      --subscribe aerospace.workspace aerospace_workspace_change

    ${sketchybarBin} --update
  '';

  # alt-N / alt-shift-N bindings for workspaces 1..9, generated instead of
  # hand-repeated so the direct-jump and send-to-workspace tables can't drift
  # out of sync with each other.
  workspaceNumberBindings = lib.listToAttrs (
    lib.concatMap (n: [
      (lib.nameValuePair "alt-${toString n}" "workspace ${toString n}")
      (lib.nameValuePair "alt-shift-${toString n}" "move-node-to-workspace ${toString n}")
    ]) (lib.range 1 9)
  );
in
{
  programs.aerospace = {
    enable = true;
    # Let home-manager's launchd agent own AeroSpace's lifecycle instead of
    # AeroSpace's built-in start-at-login, so after-startup-command runs
    # exactly once per real startup (see home-manager module for details).
    launchd.enable = true;

    settings = {
      # See https://nikitabobko.github.io/AeroSpace/guide#normalization
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      # Padding for the accordion (window-stack) layout, see alt-s below.
      accordion-padding = 30;

      # Dynamic tiling by default, like the Hyprland/COSMIC setup this
      # replaces. Toggled per-window into floating (alt-g) or accordion
      # (alt-s) on demand rather than changed globally.
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";

      gaps = {
        inner.horizontal = 8;
        inner.vertical = 8;
        outer.left = 8;
        outer.bottom = 8;
        outer.top = 8;
        outer.right = 8;
      };

      # NOTE: no `workspace-to-monitor-force-assignment` here — this machine
      # currently has a single display and nothing in this repo describes a
      # multi-monitor layout to assign workspaces against. Add it here (see
      # https://nikitabobko.github.io/AeroSpace/guide#assign-workspaces-to-monitors)
      # if/when a second monitor setup needs declaring.

      # JankyBorders and SketchyBar are started here, once, by AeroSpace
      # itself, rather than via their own separate launchd agents — keeps a
      # single, obvious lifecycle owner instead of two competing autostart
      # mechanisms.
      after-startup-command = [
        "exec-and-forget ${bordersBin} style=round width=6.0 hidpi=off active_color=${palette.mauve} inactive_color=${palette.surface2}"
        "exec-and-forget ${sketchybarBin}"
      ];

      # Fired on every workspace focus change; updates SketchyBar's
      # workspace-indicator item. Raw argv form (not an AeroSpace command
      # string) because this calls out to an external program directly.
      exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        "${sketchybarBin} --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
      ];

      mode.main.binding = {
        # Ctrl + arrows -> focus window in direction (was Cmd + arrows)
        ctrl-left = "focus left";
        ctrl-down = "focus down";
        ctrl-up = "focus up";
        ctrl-right = "focus right";

        # Ctrl+Shift + arrows -> move window in direction (was Cmd+Shift + arrows)
        ctrl-shift-left = "move left";
        ctrl-shift-down = "move down";
        ctrl-shift-up = "move up";
        ctrl-shift-right = "move right";

        # Ctrl+Alt + Up/Down -> workspace above/below (was Cmd+Ctrl+Up/Down;
        # COSMIC Super+Ctrl+Up/Down)
        ctrl-alt-up = "workspace --wrap-around prev";
        ctrl-alt-down = "workspace --wrap-around next";

        # Ctrl+Shift+Alt + Left/Right -> send focused window to prev/next
        # workspace (was Cmd+Shift+Ctrl + Left/Right)
        ctrl-shift-alt-left = "move-node-to-workspace --wrap-around prev";
        ctrl-shift-alt-right = "move-node-to-workspace --wrap-around next";

        # Alt+G -> toggle floating/tiling (was Cmd+G; COSMIC Super+G)
        alt-g = "layout floating tiling";

        # Alt+S -> toggle accordion "window stack" (was Cmd+S; COSMIC Super+S)
        alt-s = "layout accordion tiles";

        # Alt+V -> toggle split direction (was Cmd+V; Hyprland mainMod+V)
        alt-v = "layout horizontal vertical";
      }
      # Alt+1..9 -> jump to workspace N; Alt+Shift+1..9 -> send window to workspace N
      // workspaceNumberBindings;

      # A few apps whose windows don't make sense tiled at an arbitrary
      # fraction of the screen — floated instead of forced into the tiling
      # tree. AeroSpace otherwise tiles every window it sees with no
      # exceptions, which is what made System Settings/Finder windows look
      # squashed into a sliver on first activation.
      on-window-detected = [
        { "if".app-id = "com.apple.systempreferences"; run = "layout floating"; }
        { "if".app-id = "com.apple.finder"; run = "layout floating"; }
        { "if".app-id = "com.raycast.macos"; run = "layout floating"; }
      ];
    };
  };

  home.packages = [
    pkgs.sketchybar
    pkgs.jankyborders
  ];

  xdg.configFile."sketchybar/sketchybarrc" = {
    source = sketchybarrc;
  };
}
