{ config, pkgs, ... }:

{
  home.username = "mhoffm";
  home.homeDirectory = "/var/home/mhoffm";
  home.stateVersion = "22.11";
  home.shellAliases = {
    ls = "ls -ha --color -v --group-directories-first";
    ll = "ls -lha --color -v --group-directories-first";
  };
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;

  imports = [
    ./nvim.nix
    ./wm.nix
    ./programs.nix
    ./systemd.nix
  ];

  # Session Variables
  systemd.user.sessionVariables = {
    # so sway can access path
    PATH = "$HOME/go/bin:$HOME/.local/bin:$HOME/.nix-profile/bin:/bin:$PATH";
    # we want neovim for everything
    EDITOR = "nvim";
    # sway needs those
    XDG_CURRENT_DESKTOP = "sway:GNOME";
    XDG_SESSION_TYPE = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = 1;
  };
}
