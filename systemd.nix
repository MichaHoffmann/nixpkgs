{ config, pkgs, ... }:

{
  systemd.user.services = {
    update-user-flatpak = {
      Unit = {
        Description = "Update user flatpaks";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "/usr/bin/flatpak --user update -y";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
  systemd.user.timers = {
    update-user-flatpak = {
      Unit = {
        Description = "Update user flatpaks daily";
      };
      Timer = {
        OnCalendar = "daily";
        Persistent = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
