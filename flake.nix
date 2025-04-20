{
  description = "My NixOS configuration";
  # Inputs
  inputs = {
    h-m-m.url = "github:fmway/h-m-m";
    h-m-m.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-24_05.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-24_11.url = "github:NixOS/nixpkgs/nixos-24.11";
    master.url = "github:NixOS/nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
    # TODO implement impermanence
    # impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.darwin.follows = "";
    };
    fmway-nix = {
      url = "github:fmway/fmway.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # flox.url = "github:flox/flox/v1.3.17";
    fmpkgs.url = "github:fmway/fmpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixvim.url = "github:nix-community/nixvim";
    # nixvim.inputs.nixpkgs.follows = "nixpkgs";
    nvchad = {
      url = "github:fmway/NvChad.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixvim.follows = "nixvim";
    };
    encore.url = "github:encoredev/encore-flake";
    encore.inputs.nixpkgs.follows = "nixpkgs";
    # TODO
    # nix-colors.url = "github:misterio77/nix-colors";
    home-manager.url = "github:nix-community/home-manager/master";
    # nixgl.url = "github:nix-community/NixGL";
    nur.url = "github:nix-community/nur";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs = { flake-parts, home-manager, nixpkgs, fmway-nix, ... } @ inputs: let
    inherit (inputs) self;
  in flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {
        lib = nixpkgs.lib.extend (_: _: {
          inherit (home-manager.lib) hm;
          flake-parts = flake-parts.lib;
          fmway = fmway-nix.fmway // self.lib;
          inherit (fmway-nix) infuse;
        });
      };
    } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      imports = [
        ./top-level
        ({ lib, ... }: { _module.args.version = lib.fileContents ./.version; })
      ];
    };
  nixConfig = {
    extra-trusted-substituters = [
      "https://cache.nixos.org/"
      "https://chaotic-nyx.cachix.org"
      "https://devenv.cachix.org"
      "https://fmcachix.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "fmcachix.cachix.org-1:Z5j9jk83ctoCK22EWrbQL6AAP3CTYnZ/PHljlYSakrw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    extra-experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
  };
}
