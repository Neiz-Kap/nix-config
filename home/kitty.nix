{ pkgs, lib, ... }:
{
  programs.kitty = {
    enable = true;

    # On macOS the Homebrew cask provides the .app bundle with GPU driver integration.
    # Setting package = null skips installing the Nix binary while still writing kitty.conf.
    package = if pkgs.stdenv.isDarwin then null else pkgs.kitty;

    font = {
      name = "Fira Code";
      size = 13.0;
    };

    settings = {
      cursor_shape            = "beam";
      window_margin_width     = "21.75";
      confirm_os_window_close = 0;
      shell                   = "fish";
      copy_on_select          = "clipboard";

      # Catppuccin Macchiato — exact values from current-theme.conf
      foreground           = "#CAD3F5";
      background           = "#24273A";
      selection_foreground = "#24273A";
      selection_background = "#F4DBD6";

      cursor           = "#F4DBD6";
      cursor_text_color = "#24273A";

      url_color = "#F4DBD6";

      active_border_color   = "#B7BDF8";
      inactive_border_color = "#6E738D";
      bell_border_color     = "#EED49F";

      wayland_titlebar_color = "system";
      macos_titlebar_color   = "system";

      active_tab_foreground   = "#181926";
      active_tab_background   = "#C6A0F6";
      inactive_tab_foreground = "#CAD3F5";
      inactive_tab_background = "#1E2030";
      tab_bar_background      = "#181926";

      mark1_foreground = "#24273A";
      mark1_background = "#B7BDF8";
      mark2_foreground = "#24273A";
      mark2_background = "#C6A0F6";
      mark3_foreground = "#24273A";
      mark3_background = "#7DC4E4";

      # 16 terminal colors
      color0  = "#494D64";
      color1  = "#ED8796";
      color2  = "#A6DA95";
      color3  = "#EED49F";
      color4  = "#8AADF4";
      color5  = "#F5BDE6";
      color6  = "#8BD5CA";
      color7  = "#B8C0E0";
      color8  = "#5B6078";
      color9  = "#ED8796";
      color10 = "#A6DA95";
      color11 = "#EED49F";
      color12 = "#8AADF4";
      color13 = "#F5BDE6";
      color14 = "#8BD5CA";
      color15 = "#A5ADCB";
    };

    keybindings = {
      "ctrl+c"          = "copy_or_interrupt";
      "ctrl+plus"       = "change_font_size all +1";
      "ctrl+equal"      = "change_font_size all +1";
      "ctrl+kp_add"     = "change_font_size all +1";
      "ctrl+minus"      = "change_font_size all -1";
      "ctrl+underscore" = "change_font_size all -1";
      "ctrl+kp_subtract" = "change_font_size all -1";
      "ctrl+0"          = "change_font_size all 0";
      "ctrl+kp_0"       = "change_font_size all 0";
    };
  };
}
