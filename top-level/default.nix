{ self, lib, inputs, inputs', ... }: {
  debug = true;
  imports = inputs.fmway-nix.fmway.genImports ./.; # don't use lib.fmway because that would be infinite recursion
  flake.lib = {
    mkFishPath = pkgs:
      lib.pipe pkgs [
        (lib.makeBinPath)
        (lib.splitString ":")
        (map (x: /* sh */ "fish_add_path ${x}"))
        (lib.concatStringsSep "\n")
      ];
    # Will be imported to configuration and home-manager
    genSpecialArgs = { ... } @ var: let
      specialArgs = {
        inherit specialArgs lib;
        inputs = lib.recursiveUpdate inputs (lib.optionalAttrs (var ? inputs && builtins.isAttrs var.inputs) var.inputs);
        # outputs = outputs // lib.optionalAttrs (var ? outputs && builtins.isAttrs var.outputs) var.outputs;
        system =
          if var ? system && builtins.isString var.system then
            var.system
          else "x86_64-linux";
        root-path =
          "${specialArgs.inputs.self.outPath}";
        extraSpecialArgs = lib.fmway.excludeItems [ "lib" ] specialArgs;
      } // (lib.fmway.excludeItems [ "inputs" "outputs" "system" ] var);
    in specialArgs;

    # TODO
    # mkNixos :: { inputs, outputs, system ? x86_64-linux, specialArgs ? {}, users ? [], disableModules ? [], modules ? [], withHomeManager :: (bool | list of user) } -> lib.nixosSystem
    mkNixos =
      { inputs
      , system ? "x86_64-linux"
      , specialArgs ? {}
      , users ? [] # (list of str or attrsOf (attrs | string<user> -> attrs | { config, lib, pkgs, user } -> attrs))
      , defaultUser ? (
          if users == [] || (builtins.isAttrs users && users == {}) then
            null
          else if builtins.isAttrs users then
            builtins.elemAt (builtins.attrNames users) 0
          else builtins.elemAt users 0
      ) # (null | one of users)
      , disableModules ? [] # TODO
      , modules ? []
      , withHM ? true # (bool | list selected user)
      , sharedHM ? false
      , ... } @ args: let
      generatedSpecialArgs = self.lib.genSpecialArgs {
        inherit system inputs;
      } // specialArgs;
      generatedUsers = vars: let
        result =
          if builtins.isList users && builtins.all (x: builtins.isString x) users then
            self.lib.genUsers users (user: { home = "/home/${user}"; })
          else if builtins.isAttrs users then
            builtins.listToAttrs (map (username: let
              options = users.${username};
            in {
              name = username;
              value =
                if builtins.isAttrs options then
                  (self.lib.genUser username options).${username}
                else if builtins.isFunction options then
                  let
                    funcArgs = builtins.functionArgs options;
                    varu =
                      if funcArgs == {} then
                        username
                      else let
                        ctx = vars // { user = username; };
                        argsOpt = builtins.filter (x: ! funcArgs.${x}) (builtins.attrNames funcArgs);
                      in builtins.listToAttrs (map (name: {
                        inherit name;
                        value = if ctx ? ${name} then ctx.${name} else throw "Unknown argument ${name} in users with name ${username}";
                      }) argsOpt);
                  in 
                    (self.lib.genUser username (options varu)).${username}
                else
                  throw "Unknown type ${builtins.typeOf options} for users with name ${username}"
              ;
            }) (builtins.attrNames users))
          else throw "Unknown type ${builtins.typeOf users} for users, must be (listOf str | str -> attrs | { config, lib, pkgs, user } -> attrs)";
      in result;
    in lib.nixosSystem {
      inherit system;
      inherit (generatedSpecialArgs) specialArgs;
      modules = modules ++ [
          ({ pkgs, lib, ... } @ vars: {
            data = { inherit disableModules defaultUser; };
            nixpkgs.overlays = [ (_: _: {
              inherit lib;
            }) ];
            users.users = generatedUsers vars;
          })
          ({ lib, config, ... }: {
            options.users.users = lib.mkOption {
              type = lib.types.attrsOf (lib.types.submodule {
                options.hideUser = lib.mkOption {
                  type = with lib.types; nullOr bool;
                  default = null;
                  description = "hide user from login page";
                };
                options.avatar = lib.mkOption {
                  type = with lib.types; nullOr (either str path);
                  default = null;
                };
              });
            };

            config.system.activationScripts.disableUser = let
              cfg = config.users.users;
              users =
                lib.filter (x: lib.isBool cfg.${x}.hideUser) (builtins.attrNames cfg);
            in lib.mkIf (users != []) {
              # Run after /dev has been mounted
              deps = [ "specialfs" ];
              text = lib.pipe users [
                (map (user: ''
                  cat <<EOF > /var/lib/AccountsService/users/${user}
                  [User]
                  ${lib.concatStringsSep "\n" [
                    "Language="
                    "SystemAccount=${builtins.toJSON cfg.${user}.hideUser}"
                    "Icon=${lib.optionalString (!isNull cfg.${user}.avatar) (toString cfg.${user}.avatar)}"
                  ]}
                  EOF
                ''))
                (lib.concatStringsSep "")
              ];
            };
          })
        ]
        ++ lib.optionals ((builtins.isBool withHM && withHM) || builtins.isList withHM)
        (let
          allUser =
            if builtins.isAttrs users then
              builtins.attrNames users
            else users;
          ctxUsers =
            if builtins.isBool withHM then
              allUser
            else withHM;
          backupFileExtension =
            "hm-backup~.${toString inputs.self.lastModified}";
        in lib.throwIf (ctxUsers != [] && builtins.all (x: ! builtins.any (y: x == y) allUser) ctxUsers) "some users in withHM are not found in users" [
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              verbose = true;
              sharedModules = lib.optionals sharedHM
                [
                  self.homeManagerModules.modules
                  self.homeManagerModules.another
                ];
              users = builtins.listToAttrs (map (name: {
                inherit name;
                value.imports =
                  if sharedHM then
                    [ self.homeManagerModules.only ]
                  else [ self.homeManagerModules.default ];
              }) ctxUsers);
              inherit backupFileExtension;
              inherit (generatedSpecialArgs) extraSpecialArgs;
            };
          }
          inputs.home-manager.nixosModules.home-manager
        ])
      ;
    };

    genUser = name: {
      description ? name,
      isNormalUser ? true,
      home ? "/home/${name}",
      extraGroups ? [
        "networkmanager" 
        "docker" 
        "wheel"
        "video"
        "gdm"
        "dialout"
        "kvm"
        "adbusers"
        "vboxusers"
        "fwupd-refresh"
      ],
      ... } @ args: {
        ${name} = args // {
          inherit description isNormalUser home extraGroups;
        };
    };

    genUsers = users: options: # users :: lists, options :: ( attrs | str -> attrs )
      if ! (builtins.isList users && (builtins.length users == 0 && true || builtins.all (x: builtins.isString x) users)) then
        abort "first params of genMultipleUser must be a list of string"
      else if ! (builtins.isAttrs options ||
        (builtins.isFunction options && builtins.isAttrs (options "test"))) then
        abort "second params of genMultipleUser must be an attrs or function that return attrs"
      else
      builtins.listToAttrs (map (name: {
        inherit name;
        value =
          if builtins.isAttrs options then
            (self.lib.genUser name options).${name}
          else
            (self.lib.genUser name (options name)).${name};
      }) users)
    ;
  };
}
