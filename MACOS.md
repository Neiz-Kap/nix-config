# macOS

Detailed macOS-specific setup, activation behaviour, and the AeroSpace tiling
window manager stack. See [README.md](README.md) for the rest (repo layout,
Arch Linux, Neovim, Maintenance).

---

## Fresh install

### 1. Install Nix

Use the [Determinate Systems installer](https://determinate.systems/posts/determinate-nix-installer) — it handles macOS volumes and SIP correctly and enables flakes out of the box:

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Or use the official installer from [nixos.org/download](https://nixos.org/download):

```sh
sh <(curl -L https://nixos.org/nix/install)
```

Restart your terminal after installation.

### 2. Enable flakes

Skip this step if you used the Determinate Systems installer — flakes are already enabled.

```sh
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

### 3. Install Homebrew

nix-darwin manages what is installed via Homebrew but does not install Homebrew itself.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 4. Clone this repo

The config expects to live at `~/.dotfiles/nix` — the fish abbreviations (`nrs`, `nfu`) and neovim symlink both reference `~/.dotfiles`.

```sh
mkdir -p ~/.dotfiles
git clone https://github.com/Neiz-Kap/nix-config ~/.dotfiles/nix
cd ~/.dotfiles/nix
```

If you clone somewhere else, update the paths in `home/fish.nix` (the `nrs`/`hms`/`nfu` abbreviations) and `home/neovim.nix` before applying.

### 5. Bootstrap nix-darwin

`darwin-rebuild` isn't installed yet on a fresh machine, so the very first run pulls it straight from the `nix-darwin` flake input (takes 15–30 min on first run):

```sh
sudo nix run nix-darwin -- switch --flake ~/.dotfiles/nix#macos
```

This builds the system, applies all system preferences, runs Homebrew, activates home-manager, **and** registers the build under `/nix/var/nix/profiles/system` — that registration is what lets `/run/current-system` (and your login shell) survive a reboot.

For every change after this, use `darwin-rebuild` directly (see [Maintenance](README.md#maintenance)):

```sh
sudo darwin-rebuild switch --flake ~/.dotfiles/nix#macos
```

> **Do not** use the manual `nix build .#darwinConfigurations.macos.system` + `sudo ./result/activate` two-step some older guides suggest. It activates the build directly and skips the profile-registration step above, which leaves `/nix/var/nix/profiles/system` empty — the system then fails to relink `/run/current-system` on every subsequent boot, breaking the default shell and any command that depends on `/run/current-system/sw/bin`.

> You may see `warning: unknown setting 'environment.systemPackages'` during the build — this comes from the pre-existing `/etc/nix/nix.conf` and is harmless. nix-darwin replaces that file on activation.

### 6. Reload your shell

```sh
exec fish
```

---

## What changes on activation

| Setting | Value |
|---|---|
| Hostname | `macos` |
| Computer name | `Neiz-Kap's Mac` |
| Default shell | Fish (from Nix store) |
| Touch ID for sudo | enabled |
| Dock | auto-hide, bottom, 48 px tiles, no recents |
| Finder | list view, path bar, status bar, show extensions |
| Trackpad | tap to click, three-finger drag |
| Screenshots | `~/Pictures/Screenshots` |
| Key repeat | fast (InitialKeyRepeat 15, KeyRepeat 2) |
| Natural scrolling | disabled |
| Dark mode | enabled |
| Git identity | `Neiz-Kap` / `ivan.mehedoff@yandex.ru` |

> **Homebrew cleanup is set to `zap`** — any cask you installed manually that is not declared in `darwin/homebrew.nix` will be removed on activation. Add it to the file first if you want to keep it.

---

## Installed GUI apps (via Homebrew)

`kitty` · `tabby` · `termic` · `vscodium` · `zed` · `cursor` · `obsidian` · `onlyoffice` · `bitwarden` · `tableplus` · `bruno` · `postman` · `telegram` · `docker` · `vlc` · `obs` · `windows-app` · `happ` · `raycast` · `karabiner-elements`

---

## Tiling window manager: AeroSpace + SketchyBar + JankyBorders

Declared in [`home/aerospace.nix`](home/aerospace.nix), wired into the macOS
home-manager config via `home-manager.sharedModules` in `flake.nix` (not
through `home/default.nix`, which is shared with the Linux/Hyprland config).

This replaces the Hyprland/COSMIC tiling workflow from Arch. Bindings mirror
[COSMIC's keyboard shortcuts](https://system76.com/support/articles/pop-cosmic-keyboard-shortcuts)
structurally (same tiers, same modifier deltas between tiers), but land on
**Ctrl** (arrow-based tiers) and **Option/Alt** (letter- and number-based
tiers) instead of Cmd.

**Why not Cmd**, despite the spec translating Super → Cmd literally: Cmd is
not free real estate on macOS the way Super is on Linux. `Cmd+V`/`Cmd+S` are
Paste/Save in essentially every app, `Cmd+G` is Find Next in many, and
`Cmd`+arrows / `Cmd+Shift`+arrows are line navigation/selection in every text
field, system-wide. Binding these globally to AeroSpace silently broke Paste,
Save, and text navigation everywhere — found out the hard way after the
first real-world activation. Ctrl was picked over Option for the arrow tiers
because its only conflict (Mission Control's Ctrl+arrow space-switching, see
[Manual steps](#manual-steps-nix-cant-do-these) below) is a one-time System
Settings toggle, whereas Option+arrows collides with word-by-word text
navigation — a conflict with no toggle, misfiring in every text field.

### Keybindings

| Keys | Action |
|---|---|
| `Ctrl` + arrows | Focus window in direction |
| `Ctrl+Shift` + arrows | Move window in direction |
| `Ctrl+Alt` + `Up`/`Down` | Switch to workspace above/below (wraps around) |
| `Alt` + `1`–`9` | Jump to workspace N |
| `Ctrl+Shift+Alt` + `Left`/`Right` | Send focused window to prev/next workspace (wraps around) |
| `Alt+Shift` + `1`–`9` | Send focused window to workspace N |
| `Alt+G` | Toggle floating / tiling |
| `Alt+S` | Toggle accordion ("window stack", like COSMIC `Super+S`) |
| `Alt+V` | Toggle split direction (horizontal/vertical) |

Gaps (inner + outer) are set to `8` for a tidy default look.

System Settings, Finder, and Raycast windows are floated instead of tiled
(`on-window-detected` in `home/aerospace.nix`) — without this, AeroSpace
tiles every window it sees with no exceptions, which is what made these in
particular look squashed into a thin sliver right after the first
activation. Add more `app-id`s there if another app's windows don't make
sense tiled.

### Autostart

JankyBorders (active-window border, Catppuccin Macchiato mauve) and
SketchyBar (status bar with a workspace indicator) are **not** managed by
their own launchd agents. They're started once by AeroSpace itself via
`after-startup-command`, and SketchyBar's workspace label is kept in sync
via `exec-on-workspace-change`. This keeps a single, obvious lifecycle owner
instead of two competing autostart mechanisms.

AeroSpace itself autostarts through a home-manager-managed launchd agent
(`programs.aerospace.launchd.enable = true`).

**Consequence:** `aerospace reload-config` (or re-running `darwin-rebuild
switch` while AeroSpace is already running) does **not** restart
SketchyBar/JankyBorders — `after-startup-command` only fires when the
AeroSpace *process* starts, not on every config reload. After changing
`home/aerospace.nix` on a live system, restart them manually:

```sh
killall sketchybar borders
```

(or just log out/in — the launchd agent restarts AeroSpace, which restarts both).

### Manual steps (Nix can't do these)

1. **Accessibility** — System Settings → Privacy & Security → Accessibility → grant `AeroSpace.app`. Without this it cannot move or tile windows.
2. **Mission Control shortcuts (required, not optional)** — System Settings → Keyboard → Keyboard Shortcuts → Mission Control, and disable/rebind: "Mission Control" (`Ctrl+Up`), "Application windows" (`Ctrl+Down`), "Move left a space" (`Ctrl+Left`), "Move right a space" (`Ctrl+Right`). These are bound to bare `Ctrl+arrow` by default on macOS and take the keypress before AeroSpace ever sees it, so the `Ctrl`+arrow focus/move bindings above silently do nothing until these are cleared.
3. **Login Items** — the first activation prompts you to confirm the AeroSpace background item under System Settings → General → Login Items.
4. **Screen Recording** — only if/when you extend `home/sketchybar/sketchybarrc` with plugins that read window titles or screen content; the current minimal workspace-indicator config doesn't need it, and SketchyBar won't even appear in the Screen Recording list until something actually requests it.
5. **Native fullscreen** — disable it per-app for anything you tile often; it doesn't play well with AeroSpace's tiling (see Limitations below). This isn't declarable through Nix.

### Limitations

- **No animations.** AeroSpace deliberately has no window/workspace-switch animations — a conscious tradeoff for speed and reliability, and part of why it doesn't need SIP disabled the way yabai does. This is not worked around.
- **Pre-1.0 software** (0.20.3-Beta at the time of writing). Known rough edges:
  - drag-to-rearrange with the mouse is less predictable than in i3/Hyprland;
  - native macOS fullscreen doesn't coexist well with tiling — disable it per-app where it matters (see above);
  - `--wrap-around` on workspace switching makes navigation cyclic, which is a deliberate UX choice here and slightly wider than stock i3/Hyprland/COSMIC behaviour.
- **No multi-monitor workspace assignment.** The machine this was set up on has a single display, and nothing else in this repo describes a multi-monitor layout. `workspace-to-monitor-force-assignment` is left as a comment in `home/aerospace.nix` — fill it in when a second monitor needs a declared layout (see the [AeroSpace guide](https://nikitabobko.github.io/AeroSpace/guide#assign-workspaces-to-monitors)).
- **yabai is not a fallback.** If AeroSpace is missing something, treat it as a limitation to note, not a reason to switch WMs (which would mean disabling SIP).
