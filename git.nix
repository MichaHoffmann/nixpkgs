{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Michael Hoffmann";
    userEmail = "michael.hoffmann@aiven.io";

    extraConfig = {
      signing = {
        key = "216B5666D440F1F6";
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
}

