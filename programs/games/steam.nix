{ pkgs, lib, config, ... }:
{
  enable = lib.mkForce (! config.data ? isMinimal || ! config.data.isMinimal);
  #remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  gamescopeSession = {
    enable = true;
    # env = {};
    # args = [];
  };
  
  protontricks.enable = true;
  extraPackages = with pkgs; [
  ];
  extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];
}
