{ config, pkgs, ... }:

{
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableBashIntegration = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    sshKeys = [ "8EA14B669807C630BE4DD610CEB5CE1483F7FC79" ];
  };
}

