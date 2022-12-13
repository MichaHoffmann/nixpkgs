{ config, pkgs, ... }:

{
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
