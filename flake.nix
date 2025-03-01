{
  description = "My NixOS configuration";

  # Inputs
  inputs = {
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
    nixgl.url = "github:nix-community/NixGL";
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
        });
      };
    } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      imports = [
        ./top-level
      ];
    };
}
