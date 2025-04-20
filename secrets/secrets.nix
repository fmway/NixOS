let
  keys = {
    system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO58iqlTtlgkt9e8u7X6hbBusv6yf9LGJGk16/YhVDOw";
    fmway = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGM2l3zhUoxYpBzzmH7KsWdo1XMrc1eCgNrwaIHVM2pZ";
  };
  
  mySecret = arr: builtins.listToAttrs (map (name: {
    name = "${name}.age";
    value.publicKeys = builtins.attrValues keys;
  }) arr);

in mySecret [ 
  "cloudflared"
  "wg0-private"
  "nix" # another nix.conf with encryption
  "tailscale"
  # "fmway"
] 
