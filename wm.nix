{ config, pkgs, ... }:

{
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
}
