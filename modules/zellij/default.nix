{ config, lib, ... }:
{
  options.features.zellij.enable = lib.mkEnableOption "the personal Zellij configuration";
  config.outputs.homeManager = lib.mkIf config.features.zellij.enable (import ./home.nix);
}
