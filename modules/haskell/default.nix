{ config, lib, ... }:
{
  options.features.haskell.enable = lib.mkEnableOption "a GHC environment with haskell-language-server";

  config = lib.mkIf config.features.haskell.enable {
    outputs.homeManager = import ./home.nix;

    # The editor consumes this only when selected in this same profile.
    features.neovim.lspConfig = ''
      vim.lsp.config('hls', {
        settings = {
          haskell = {
            formattingProvider = "fourmolu"
          }
        }
      })
      vim.lsp.enable('hls')
    '';
  };
}
