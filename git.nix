{ config, pkgs, ... }:

{
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
      push = {
        autoSetupRemote = true;
      };
    };
  };
}

