{ pkgs, ... }:
(with pkgs.nur.repos.rycee.firefox-addons; [
  metamask
  multi-account-containers
  greasemonkey
  gesturify
  tree-style-tab
  react-devtools
  search-by-image
  firefox-color
  vue-js-devtools
]) ++ (with pkgs.fmpkgs.firefox-addons; [
  what-font
  wakatime
  stayfree
  firefox-relay
  preact-devtools
])
