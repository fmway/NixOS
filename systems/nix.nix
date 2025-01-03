{ pkgs, inputs, config, ... }:
{
  settings = {
    # Enable the Flakes feature and the accompanying new nix command-line tool
    experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
    trusted-users = [
      "root"
      "fmway"
    ];
    trusted-substituters = [
      # "https://cache.flox.dev"
    ];
    trusted-public-keys = [
      # "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
    ];
    # auto optimise the store
    auto-optimise-store = true;
  };

  registry = builtins.attrNames inputs
    |> map (x: {
      name =
        if x == "self" then
          "nixos"
        else
          x;
      value.flake = inputs.${x};
    })
    |> builtins.listToAttrs;

  nixPath = builtins.attrNames inputs
    |> map (name: "${name}=${inputs.${name}.outPath}");

  gc = {
    automatic = true;
    dates = "Mon,Fri *-*-* 00:00:00";
    options = "--delete-older-than 3d";
  };
  extraOptions = ''
    !include ${config.age.secrets.nix.path}
  '';
}
