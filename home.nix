{ config, pkgs, ... }:

let

  pw-volume = pkgs.rustPlatform.buildRustPackage {
    name = "pw-ctl";
    src = pkgs.fetchFromGitHub {
      owner = "smasher164";
      repo = "pw-volume";
      rev = "be104eaaeb84def26b392cc44bb1e7b880bef0fc";
      hash = "sha256-mFvXpz2Iire3Tcv15HVqCLFRKFjVJ7+hlHn9Yb8QKTU=";
    };
    cargoHash = "sha256-giA0bhOYtvj5HNq3Spdijelk+q1kx8gtnA69Z4USTFQ=";
  };

in

{
  home.username = "michael.hoffmann";
  home.homeDirectory = "/home/michael.hoffmann";
  home.stateVersion = "22.11";
  home.packages = with pkgs; [
    brightnessctl
    flameshot
    silver-searcher
    pw-volume
    wl-clipboard
  ];
  home.shellAliases = {
    ls = "ls -a --color";
    ll = "ls -la --color";
    AVN-ADMINAPI = ''PYTHONPATH=/home/michael.hoffmann/git/aiven/aiven-core-master python3 -m aiven.rest.admin.cli --api-production'';
    AAPI = "AVN-ADMINAPI";
    AVN-PROD = ''PYTHONPATH=/home/michael.hoffmann/git/aiven/aiven-core-master python3 -m aiven.admin --config gopass:aiven/aivenprod/config.json --operator-config gopass:aiven-operator/aivenprod.json --sky aiven'';
  };
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;

  imports = [
    ./nvim.nix
    ./git.nix
    ./wm.nix
    ./shell.nix
  ];


  # Flatpak Wrappers
  home.file.".flatpak" = {
    source = ./config/flatpak/.flatpak;
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
