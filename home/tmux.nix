{ pkgs, ... }:
{
  programs.tmux = {
    enable   = true;
    mouse    = true;
    terminal = "screen-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'macchiato'
          set -g @catppuccin_window_default_text "#W"
          set -g @catppuccin_window_current_text "#W"
        '';
      }
      yank
      resurrect
      {
        plugin = continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
    ];

    extraConfig = ''
      # Split with current path
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Vim-like pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Faster prefix response
      set -sg escape-time 10
      set -g focus-events on
    '';
  };
}
