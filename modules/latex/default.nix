{ config, lib, ... }:
{
  options.features.latex.enable = lib.mkEnableOption "the TeX language server";

  config = lib.mkIf config.features.latex.enable {
    outputs.homeManager = import ./home.nix;

    # The editor consumes this only when selected in this same profile.
    features.neovim.lspConfig = ''
      vim.lsp.enable('texlab')
    '';
  };
}
