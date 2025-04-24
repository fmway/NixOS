{ pkgs
, lib
, inputs
, config
, ...
} @ variables
: let
  inherit (pkgs.functions)
    genPaths
  ;
  inherit (config.home) homeDirectory username;
in
{
  imports = [
    ./desktop
    {
      home = lib.fmway.treeImport {
        inherit variables;
        folder = ./.;
        max = 1;
      };
    }
  ];

  programs.home-manager.enable = true;

  home = {
    # Home Manager version
    stateVersion = lib.mkIf (variables ? osConfig) (lib.mkDefault (variables.osConfig.system.stateVersion));

    sessionPath = map (x: "${homeDirectory}/${x}/bin") [
      ".local" # must be ${home}/.local/bin
      ".cargo" # etc
      ".deno"
      ".bun"
      ".foundry"
    ];

    sessionVariables = rec {
      ASSETS = "${homeDirectory}/assets";
      ASET = "${homeDirectory}/aset";
      GITHUB = "${ASET}/Github";
      DOWNLOADS = "${homeDirectory}/Downloads";
    } // lib.optionalAttrs (lib.pathExists "${inputs.self.outPath}/secrets/${username}.env")
      (lib.fmway.readEnv "${inputs.self.outPath}/secrets/${username}.env");

    # xkb options
    keyboard.options = [
      "grp:shifts_toggle"
      "caps:none" # disable capslock
    ];
  };

  services = {
    clipman.enable = true; # clipboard manager
    clipman.systemdTarget = "sway-session.target";
  };

  features = {
    # $HOME/.config refers to ./configs
    config.enable = true;
    config.cwd = ./configs;

    programs.auto-import = {
      enable = true;
      cwd = ./programs;
      # auto-enable = false;
      includes = let
        inherit (lib.fmway.matchers) extension json;
      in [
        (extension "fish")
        (extension "css")
        (extension "conf")
        (extension "tmux")
        (extension "sh")
        json
      ];
    };

    # install collection of scripts in ./scripts
    script.enable = true;
    script.cwd = ./scripts;
  };
}
