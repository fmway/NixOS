{ lib, ... }:
{
  settings = {
    gtk-titlebar = false;
    keybind = let
      leader = "ctrl+b";
      withLeader = lib.mapAttrsToList (name: value: "${leader}>${name}=${value}");
    in withLeader {
      "shift+six"       = "goto_tab:1"; # ^
      "shift+four"      = "last_tab"; # $
      "1"               = "goto_tab:1";
      "2"               = "goto_tab:2";
      "3"               = "goto_tab:3";
      "4"               = "goto_tab:4";
      "5"               = "goto_tab:5";
      "6"               = "goto_tab:6";
      "7"               = "goto_tab:7";
      "8"               = "goto_tab:8";
      "9"               = "goto_tab:9";
      "0"               = "goto_tab:10";
      "shift+comma"     = "move_tab:-1"; # <
      "shift+period"    = "move_tab:1"; # <
      "c"               = "new_tab";
      "shift+n"         = "previous_tab";
      "n"               = "next_tab";
      "shift+p"         = "next_tab";
      "p"               = "previous_tab";
      "comma"           = "previous_tab";
      "period"          = "next_tab";
      "h"               = "goto_split:left";
      "j"               = "goto_split:down";
      "k"               = "goto_split:up";
      "l"               = "goto_split:right";
      "z"               = "toggle_split_zoom";
      "w"               = "close_tab";
      "q"               = "quit";
      "s"               = "toggle_tab_overview";
      "f"               = "toggle_fullscreen";
      "shift+backslash" = "new_split:right";
      "minus"           = "new_split:down";
      "shift+h"         = "resize_split:left,20";
      "shift+j"         = "resize_split:down,20";
      "shift+k"         = "resize_split:up,20";
      "shift+l"         = "resize_split:right,20";
      "ctrl+b"          = "text:\\x02";
    };
  };
  installVimSyntax = true;
  installBatSyntax = true;
}
