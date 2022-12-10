{ config, pkgs, ... }:

{
  home.username = "mhoffm";
  home.homeDirectory = "/var/home/mhoffm";
  home.stateVersion = "22.11";
  home.packages = with pkgs; [
    brightnessctl
    cargo
    gcc
    go
    powertop
    silver-searcher
    wl-clipboard
  ];
  targets.genericLinux.enable = true;

  programs.home-manager.enable = true;

  programs.dircolors = {
    enable = true;
    enableBashIntegration = true;
  };
  home.file.".dir_colors" = {
    source = pkgs.fetchFromGitHub
      {
        owner = "dracula";
        repo = "dircolors";
        rev = "057d17917f04ac258d5333416897a30a2d2b89ad";
        sha256 = "sha256-gvBlTIDJYxlgEo0tWPOeWqDvnT1M0ICDpXzekF/+lEs=";
      } + "/.dircolors";
  };

  programs.powerline-go = {
    enable = true;
    newline = true;
    modules = [ "host" "ssh" "cwd" "gitlite" "jobs" "nix-shell" ];
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -GFlha --color";
    };
  };

  programs.fzf = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Michael Hoffmann";
    userEmail = "mhoffm@posteo.de";

    extraConfig = {
      signing = {
        key = "643EE7190C2D8F047D46A0A3E0DBDF3D046F608E!";
        signByDefault = true;
      };
      init = {
        defaultBranch = "main";
      };
      commit = {
        gpgsign = true;
      };
    };
  };

  programs.neovim.enable = true;
  xdg.configFile.nvim = {
    source = ./config/nvim;
    recursive = true;
  };

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
  };

  programs.password-store.enable = true;

  # Flatpak Wrappers
  home.file.".flatpak" = {
    source = ./config/flatpak/.flatpak;
    recursive = true;
  };

  # Window Manager is managed by Fedora Silverblue
  xdg.configFile.sway = {
    source = ./config/sway;
    recursive = true;
  };
  xdg.configFile.waybar = {
    source = ./config/waybar;
    recursive = true;
  };
  xdg.configFile.alacritty = {
    source = ./config/alacritty;
    recursive = true;
  };

  # Session Variables
  systemd.user.sessionVariables = {
    # so sway can access path
    PATH = "$HOME/.nix-profile/bin:$HOME/.flatpak/bin:$PATH";
    # we want neovim for everything
    EDITOR = "nvim";
    # sway needs those
    XDG_CURRENT_DESKTOP = "sway:GNOME";
    XDG_SESSION_TYPE = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = 1;
  };
}
