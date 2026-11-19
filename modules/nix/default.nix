{ config, lib, ... }:
{
  options.features.nix.enable = lib.mkEnableOption "Nix language tooling with nil and nixfmt";

  config = lib.mkIf config.features.nix.enable {
    outputs.homeManager = import ./home.nix;

    # The editor consumes this only when selected in this same profile.
    features.neovim.lspConfig = ''
      vim.lsp.config('nil_ls', {
        settings = { ["nil"] = { formatting = { command = { "nixfmt" } } } }
      })
      vim.lsp.enable('nil_ls')
    '';
  };
}
