{ pkgs, config, ... }:
with pkgs; lib.mkIf (! config.data.isMinimal or false) [
  # cli
  element # periodic table
  encore # awesome tools for developing go and typescript
  # matui
  ttyper # monkeytype in terminal
  # mastodon
  # ytui-music
  
  # bui (browser user interface)
  filebrowser

  dconf

  # gui
  telegram-desktop
  discord
  upscayl # image upscaler
  gthumb
  # element-desktop-wayland # matrix client
  element-desktop
  foliate # reader for desktop
  # youtube-music
  # dbeaver-bin # sql client
  # weechat
  zoom-us
  libreoffice-fresh
  zotero-beta
  # anytype
  # kdenlive
  # custom.obs-studio

  # development
  # wasmer
  # rust-analyzer
  # clang-tools
  # zls
  deno
  yarn
]
