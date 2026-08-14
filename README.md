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

## macOS

Fresh-install steps, what changes on activation, the installed GUI app list,
and the AeroSpace/SketchyBar/JankyBorders tiling setup (including manual
permission steps and known limitations) now live in **[MACOS.md](MACOS.md)**.

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

Installed macOS GUI apps and the AeroSpace tiling setup are documented in [MACOS.md](MACOS.md).
