{ pkgs, lib, ... }:
{
  enable = true;
  wrapperFeatures.gtk = true;
  checkConfig = false;
  package = pkgs.custom.swayfx;
}
