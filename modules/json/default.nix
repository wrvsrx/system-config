{ config, lib, ... }:
{
  options.features.json.enable = lib.mkEnableOption "the JSON language server";

  config = lib.mkIf config.features.json.enable {
    outputs.homeManager = import ./home.nix;

    # The editor consumes this only when selected in this same profile.
    features.neovim.lspConfig = ''
      vim.lsp.enable('jsonls')
    '';
  };
}
