{ config, lib, ... }:
let
  cfg = config.features.neovim;
in
{
  options.features.neovim = {
    enable = lib.mkEnableOption "the personal Neovim configuration";
    lspConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Lua executed in the nvim-lspconfig plugin configuration, after common LSP setup.";
    };
  };

  config.outputs.homeManager = lib.mkIf cfg.enable (import ./home.nix { lspConfig = cfg.lspConfig; });
}
