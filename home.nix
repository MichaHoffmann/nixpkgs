{ config, pkgs, ... }:

let

  pw-volume = pkgs.rustPlatform.buildRustPackage {
    name = "pw-volume";
    src = pkgs.fetchFromGitHub {
      owner = "smasher164";
      repo = "pw-volume";
      rev = "be104eaaeb84def26b392cc44bb1e7b880bef0fc";
      hash = "sha256-mFvXpz2Iire3Tcv15HVqCLFRKFjVJ7+hlHn9Yb8QKTU=";
    };
    cargoHash = "sha256-Bf7B1ehAAqAcnogRei/UnD0gY0MvImjbjqjb6fnaBHc=";
  };

in

{
  home.username = "mhoffm";
  home.homeDirectory = "/var/home/mhoffm";
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
  };
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;

  imports = [
    ./nvim.nix
    ./git.nix
    ./gpg.nix
    ./wm.nix
    ./shell.nix
  ];

  # Session Variables
  systemd.user.sessionVariables = {
    # so sway can access path
    PATH = "$HOME/.nix-profile/bin:/bin:$PATH";
    # we want neovim for everything
    EDITOR = "nvim";
    # sway needs those
    XDG_CURRENT_DESKTOP = "sway:GNOME";
    XDG_SESSION_TYPE = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = 1;
  };
}
