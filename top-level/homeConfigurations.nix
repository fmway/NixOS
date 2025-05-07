{ inputs, version, self, ... }:
{
  flake.homeConfigurations.default = let
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs.legacyPackages.${system};
    specialArgs = self.lib.genSpecialArgs {
      inherit system inputs;
    };
  in inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = specialArgs // {
      lib = specialArgs.lib.extend (_: _: inputs.home-manager.lib);
    };
    modules = [
      self.homeManagerModules.modules
      self.homeManagerModules.another
      self.homeManagerModules.only
      ({ lib, config, ... }: {
        home.username = lib.mkDefault "fmway";
        home.homeDirectory = lib.mkDefault "/home/${config.home.username}";
        home.stateVersion = version;
      })
      ../programs/overlays
    ];
  };
}
