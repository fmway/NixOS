{ config, super, lib, self, ... }: let
  # config.set(xxx, yyy)
  uncommon = {
    config = {
      # fileselect.handler = "external";
    };
  };
  searchEngines = {
    w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
    aw = "https://wiki.archlinux.org/?search={}";
    nw = "https://wiki.nixos.org/index.php?search={}";
    g = "https://www.google.com/search?q={}";
    b = "https://www.bing.com/search?q={}";
    d = "https://duckduckgo.com/?q={}";
    DEFAULT = self.searchEngines.g;
  };
in {
  enable = true;
  greasemonkey = [];

  c.auto_save.session = true;
  c.url.start_pages = "https://fmway.id";
  
  extraConfig = let
    toPyValue = value:
      if isNull value then
        "None"
      else if lib.isString value then
        "'${value}'"
      else if lib.isList value then
        "[ ${lib.concatStringsSep ", " (map (x: toPyValue x) value)} ]"
      else if lib.isBool value then
        if value then
          "True"
        else "False"
      else toString value;
    describe = x: let
      func = key: y:
        if lib.isAttrs y then
          map (x: func (key ++ [ (lib.replaceStrings [ "-" ] [ "_" ] x) ]) y.${x}) (lib.attrNames y)
        else {
          inherit key;
          value = toPyValue y;
        };
    in lib.flatten (func [] x); 
    # toPy = x: lib.concatStringsSep "\n" (map (x: "${lib.concatStringsSep "." x.key} = ${x.value}") (describe x)) + "\n";
    toPyConfig = x: lib.concatStringsSep "\n" (map (x: "config.set('${lib.concatStringsSep "." x.key}', ${x.value})") (describe x)) + "\n";
  in 
    # lib.optionalString (uncommon.c or {} != {}) (toPy { inherit (uncommon) c; }) +
    lib.optionalString (uncommon.config or {} != {}) (toPyConfig uncommon.config);
  searchEngines = let
    firefox = lib.getAttrFromPath [ "firefox" "profiles" (config.data.firefoxProfileName or "namaku") ] super;
    search = lib.fmway.excludeItems [ "Google" "Wikipedia" "Bing" "DuckDuckGo" ] firefox.search.engines;
    keys = lib.attrNames search;
    prevSearch = map (x: let
      name = builtins.elemAt search.${x}.definedAliases 0
        |> lib.match "^@?(.+)$"
        |> lib.flip lib.elemAt 0;
    in {
      inherit name;
      value = lib.elemAt search.${x}.urls 0
        |> (x: let
          base = x.template;
          params = x.params or [];
          parsedParams = map ({ name, value }: "${name}=${value}") params |> lib.concatStringsSep "&";
        in lib.replaceStrings [ "{searchTerms}" ] [ "{}" ] "${base}${lib.optionalString (params != []) "?${parsedParams}"}");
      }) keys |> lib.listToAttrs;
  in prevSearch // searchEngines;

}
