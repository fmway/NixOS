{ config, ... }:
{
  socket = {
    group = config.services.caddy.group;
    user = config.users.users.fmway.name;
    mode = "0666";
  };
  process = {
    user = config.users.users.fmway.name;
    group = config.users.groups.users.name;
  };
}
