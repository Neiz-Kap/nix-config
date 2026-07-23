# nix-config

Declarative system configuration for **macOS (Apple Silicon)** and **Arch Linux**.
Built with [nix-darwin](https://github.com/LnL7/nix-darwin) + [home-manager](https://github.com/nix-community/home-manager) and themed end-to-end with [Catppuccin Macchiato](https://github.com/catppuccin/catppuccin).

---

## What this configures

| Layer | Tool | Scope |
|---|---|---|
| macOS system | nix-darwin | hostname, dock, finder, trackpad, Touch ID sudo, fonts, shell |
| macOS GUI apps | Homebrew (managed by nix-darwin) | kitty, vscodium, zed, cursor, obsidian, raycast, karabiner-elements, docker, telegram, … |
| User environment | home-manager | fish, tmux, neovim, starship, git, kitty config, all CLI tools |
| Linux system | pacman (unmanaged) | Hyprland, SDDM — outside this repo |
| Linux user env | standalone home-manager | same home modules + wl-clipboard, xdg-utils |

---

## Repo layout

```
nix-config/
├── flake.nix               # inputs + outputs (darwinConfigurations / homeConfigurations)
├── darwin/
│   ├── default.nix         # nix-darwin system module (hostname, shell, fonts, nix settings)
│   ├── homebrew.nix        # Homebrew casks managed declaratively
│   └── system-preferences.nix  # defaults write equivalents (dock, finder, trackpad, …)
├── home/
│   ├── default.nix         # home-manager entry point, session vars, XDG
│   ├── packages.nix        # all CLI packages (go, rust, python, node/volta, tools)
│   ├── fish.nix            # fish shell, abbreviations, functions
│   ├── git.nix             # git identity, delta pager, LFS, ignores
│   ├── neovim.nix          # neovim binary + symlink to LazyVim config
│   ├── kitty.nix           # kitty config + Catppuccin Macchiato colours
│   ├── tmux.nix            # tmux keybindings + catppuccin + resurrect/continuum
│   ├── starship.nix        # starship prompt (catppuccin macchiato)
│   └── fonts.nix           # user-level font installation
└── linux/
    └── default.nix         # imports home/ + Linux-specific overrides (SSH selector, AGS, Zed)
```

---

## macOS — fresh install

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

For every change after this, use `darwin-rebuild` directly (see [Maintenance](#maintenance)):

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

## macOS — what changes on activation

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

## Arch Linux — fresh install

### 1. Install Nix

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Enable the nix daemon and add yourself to the `nix-users` group (or `nixbld` depending on your distro):

```sh
sudo systemctl enable --now nix-daemon
```

### 2. Enable flakes

```sh
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

### 3. Clone this repo

```sh
mkdir -p ~/.dotfiles
git clone https://github.com/Neiz-Kap/nix-config ~/.dotfiles/nix
cd ~/.dotfiles/nix
```

### 4. Apply home-manager

```sh
nix --extra-experimental-features "nix-command flakes" run home-manager -- switch --flake .#oneivan@arch
```

### 5. Reload your shell

```sh
exec fish
```

> Hyprland, SDDM, and system-level packages stay managed by pacman outside this repo. See `linux/default.nix` for what home-manager adds on top.

---

## Neovim

Neovim is installed by Nix but the config is **not** in this repo. `home/neovim.nix` symlinks `~/.config/nvim` to `~/.dotfiles/.config/nvim`, so LazyVim's `lazy-lock.json` can be written at runtime (the Nix store is read-only).

You need your LazyVim config at that path before activating, or the symlink will be a dangling pointer. On first activation without it, Neovim starts without config — add the config and re-run the switch command.

---

## Maintenance

| Task | Command |
|---|---|
| Apply changes after editing files | `darwin-rebuild switch --flake ~/.dotfiles/nix#macos` |
| Same, via fish abbreviation | `nrs` |
| Update all flake inputs | `nix flake update ~/.dotfiles/nix` (or `nfu`) |
| Apply home-manager only (Arch) | `home-manager switch --flake ~/.dotfiles/nix#oneivan@arch` (or `hms`) |
| Garbage collect old generations | `nix-collect-garbage -d` |
| List installed packages | `nix profile list` |

---

## Installed CLI tools

`bat` · `eza` · `ripgrep` · `fd` · `fzf` · `jq` · `yq` · `btop` · `htop` · `fastfetch` · `delta` · `httpie` · `imagemagick` · `ffmpeg` · `gnupg` · `tree` · `ncdu` · `tldr` · `gh` · `git-lfs` · `go` · `rustup` · `python 3.13` · `volta` (Node) · `docker-compose` · `nil` · `nixpkgs-fmt` · `lua-language-server` · `typescript-language-server` · `ruff` · `black` · `stylua` · `prettierd` · `gcc` · `make`

## Installed GUI apps (macOS, via Homebrew)

`kitty` · `tabby` · `termic` · `vscodium` · `zed` · `cursor` · `obsidian` · `onlyoffice` · `bitwarden` · `tableplus` · `bruno` · `postman` · `telegram` · `docker` · `vlc` · `obs` · `windows-app` · `raycast` · `karabiner-elements`
