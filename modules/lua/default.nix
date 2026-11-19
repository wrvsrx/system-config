{ config, lib, ... }:
{
  options.features.lua.enable = lib.mkEnableOption "the Lua language server";

  config = lib.mkIf config.features.lua.enable {
    outputs.homeManager = import ./home.nix;

    # The editor consumes this only when selected in this same profile.
    features.neovim.lspConfig = ''
      vim.lsp.enable('lua_ls')
    '';
  };
}
