{ config, lib, ... }:
{
  options.features.python.enable = lib.mkEnableOption "a Python environment with basedpyright and ruff";

  config = lib.mkIf config.features.python.enable {
    outputs.homeManager = import ./home.nix;

    # The editor consumes this only when selected in this same profile.
    features.neovim.lspConfig = ''
      vim.lsp.enable('basedpyright')

      vim.lsp.config('ruff', {
        init_options = { settings = { lint = { enable = false } }  }
      })
      vim.lsp.enable('ruff')
    '';
  };
}
