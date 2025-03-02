{ super, self, ... }:
let
  pkgs = self;
  inherit (pkgs) lib;
  pkg = super.qutebrowser.override {
    enableWideVine = true;
  };
in pkgs.symlinkJoin {
  name = "${lib.getName pkg}-wrapped-${lib.getVersion pkg}";
  paths = [ pkg ];
  preferLocalBuild = true;
  postBuild = let
    wrap = let
      scripts = [ "dictcli" "importer" ];
    in pkgs.writeScript "qutebrowser-wrapped" /* sh */ ''
      #!${lib.getExe pkgs.bash}

      export SCRIPTS=${lib.concatStringsSep ":" scripts}

      if [[ $# -lt 1 ]]; then
        exec $out/bin/.qutebrowser
      fi

      cmd=$1
      if [[ ":''${SCRIPTS}:" =~ ":''${cmd}:" ]]; then
        shift 1
        exec "''${out}/share/qutebrowser/scripts/''${cmd}.py" $@
      else
        exec $out/bin/.qutebrowser $@
      fi
    '';
  in /* sh */ ''
    mv $out/bin/qutebrowser $out/bin/.qutebrowser
    cp -f ${wrap} $out/bin/qutebrowser
    substituteInPlace $out/bin/qutebrowser \
      --replace '$out' $out \
      --replace \''${out} $out
  '';
}
