{ pkgs, ... }:
with pkgs; [
  # cli
  element # periodic table
  # matui
  # mastodon
  # ytui-music
  
  # bui (browser user interface)
  filebrowser

  # gui
  telegram-desktop
  discord
  upscayl # image upscaler
  gthumb
  element-desktop-wayland # matrix client
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