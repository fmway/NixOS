{ config, pkgs, ... }: let 
  inherit (pkgs.functions) printPath;
  inherit (config.services) fcgiwrap certs;
in {
  type = "https";
  enable = config.data.enableCGI or true;
  extraConfig = ''
    tls ${certs.cgi.cert} ${certs.cgi.key}
    log {
      format console
      output stdout
    }
    header {
      Access-Control-Allow-Headers *
      Access-Control-Allow-Methods *
      Access-Control-Allow-Origin *
    }
    @options {
      method OPTIONS
    }
    respond @options 204
    handle_path /static/* {
      root * /srv/static
      file_server
    }
    handle {
      root * /srv/cgi
      try_files {path} {path}/index.cgi {path}/index {path}.cgi 404 404.cgi
      reverse_proxy unix/${fcgiwrap.instances.${config.data.defaultUser}.socket.address} {
        transport fastcgi {
          env PATH ${printPath config.data.defaultUser}
          split .cgi
        }
      }
    }
  '';
}
