{ pkgs, lib, ... }:
{
  org.gnome.shell = {
    disable-user-extensions = false;
    enabled-extensions = map (x:
      if builtins.isString x then
        x
      else x.extensionUuid)
    (with pkgs.gnomeExtensions; [
      blur-my-shell
      gsconnect
      paperwm
      appindicator
      clipboard-indicator
      thinkpad-battery-threshold
      blur-my-shell
      # net-speed
      totp
      cloudflare-warp-toggle
      system-monitor
      weather-oclock
      bing-wallpaper-changer
      places-status-indicator
      applications-menu
      emoji-copy
      day-progress
      lilypad
    ]);

    # extensions settings
    extensions = {
      # paperwm
      paperwm = {
        default-focus-mode = 0;
        open-window-position = 0; # right
        keybindings.toggle-scratch = [ "<Shift><Super>space" ];
      };

      system-monitor = {
        show-cpu = true;
        show-download = true;
        show-memory = true;
        show-upload = true;
        show-swap = false;
      };
    };
  };

  org.gnome.desktop = {
    interface = {
      color-scheme = "prefer-dark"; # dark mode
      cursor-theme = "Adwaita";
      cursor-size = 50;
      icon-theme = "Adwaita";
      gtk-theme = "adw-gtk3";
    };

    # Change background
    # background = {
    #   picture-uri = "file:///<path>";
    #   picture-uri-dark = "file:///<path>";
    # };
  };
}
