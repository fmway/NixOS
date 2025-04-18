{ config, inputs, lib, ... }:
{
  sessionVariables = {
    # LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
    # NIXOS_OZONE_WL = "1";
  };

  # links all (system app installed) to /run/current-system/sw
  pathsToLink = [
    "/share/fish"
  ];

  etc = lib.pipe inputs [
    (lib.attrNames)
    (map (x: {
      name = "nix/inputs/${x}";
      value.source = inputs.${x}.outPath;
    }))
    (lib.listToAttrs)
  ] // {
    "current-background".source = ./background.jpg;
  };
}
