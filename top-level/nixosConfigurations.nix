{ inputs, lib, self, ... }: let
  system = "x86_64-linux";
in {
  flake.nixosConfigurations = let
    defaultModules = with inputs; [
      ../hardware-configuration.nix
      ../disk.nix
      ../secrets
      agenix.nixosModules.default
      disko.nixosModules.default
      nixos-hardware.nixosModules.lenovo-thinkpad-t480
      self.nixosModules.default
      ({ ... }: {
        virtualisation.docker.enable = lib.mkForce false;
        networking.wireguard.enable = lib.mkForce false;
        virtualisation.virtualbox.host.enable = lib.mkForce false;
        programs.winbox.enable = lib.mkForce false;
        virtualisation.virtualbox.guest.enable = lib.mkForce false;
      })
    ];
  in  {
    Namaku1801 = self.lib.mkNixos {
      inherit system inputs;
      modules = defaultModules;
      users = {
        fmway = { user, pkgs, ... }:
        {
          home = "/home/${user}";
          shell = pkgs.fish;
        };
      };
      withHM = true;
    };
    minimal = self.lib.mkNixos {
      inherit system inputs;
      modules = defaultModules ++ [
        { data.isMinimal = true; }
      ];
      users.fmway = { pkgs, ... }: { shell = pkgs.fish; };
      withHM = [ "fmway" ];
      sharedHM = true;
    };
  };
  flake.legacyPackages.${system} = self.nixosConfigurations.Namaku1801.pkgs;
}
