{ pkgs, ... }:
{
  # cross shell completion
  carapace = {
    enable = true;
    enableFishIntegration = false;
  };

  # ls alternative
  eza = {
    enable = true;
    icons = "auto"; # display icons
    git = true; # List each file's Git status if tracked or ignored
  };

  fd.enable = true; # find alternative, more wuzz wuzz
  fd.hidden = true; # show hidden file

  jq.enable = true;

  lazygit.enable = true;

  zoxide.enable = true; # cd alternative

  translate-shell.enable = true; # google or bing translate in terminal

  yt-dlp.enable = true; # all in one video downloader

  ripgrep.enable = true; # alternative grep

  swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
  };
}
