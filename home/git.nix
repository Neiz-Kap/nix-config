{ pkgs, lib, ... }:
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name  = "Neiz-Kap";
        email = "ivan.mehedoff@yandex.ru";
      };

      core = {
        autocrlf = "input";
        editor   = "nvim";
        pager    = "delta";
      };

      push.autoSetupRemote = true;
      init.defaultBranch   = "master";
      pull.rebase          = false;
      commit.gpgsign       = false;

      interactive.diffFilter = "delta --color-only";

      delta = {
        navigate     = true;
        line-numbers = true;
        syntax-theme = "Catppuccin Macchiato";
      };

      merge.conflictstyle = "diff3";
      diff.colorMoved     = "default";

      diff.tool = "codium";
      "difftool \"codium\"".cmd = "codium --wait --diff $LOCAL $REMOTE";
    };

    signing = {
      key           = "E7B9FBDD06E83500";
      signByDefault = false;
    };

    ignores = [
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "*.swp"
      "*.swo"
      ".direnv"
      ".envrc"
      "node_modules/"
      ".volta/"
    ];

    lfs.enable = true;
  };
}
