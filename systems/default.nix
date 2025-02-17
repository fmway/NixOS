{ pkgs
, lib
, config
, ...
}
@ variables
:
let
  inherit (lib.fmway)
    treeImport
    matchers
    genTreeImports
  ;
in treeImport {
  imports = genTreeImports ./extra;

  zramSwap.enable = true;
}
{
  excludes = [
    "extra"
    # "boot/loader/grub"
    # "services/nginx"
    # "services/phpfpm"
    "networking/wg-quick"
    "networking/wireguard"
    "systemd/services"
    # "services/stubby"
  ];

  includes = with matchers; [
    (extension "conf")
    (extension "txt")
    json
  ];

  # auto-enable = [
  #   ["services"] # services.*.enable = true;
  # ];

  folder = ./.;
  inherit variables;
}
