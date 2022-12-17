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
  home.packages = with pkgs; [
    brightnessctl
    flameshot
    silver-searcher
    pw-volume
    wl-clipboard
  ];

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

  programs.bash.enable = true;
  programs.fzf.enable = true;
  programs.jq.enable = true;
  programs.password-store.enable = true;
}
