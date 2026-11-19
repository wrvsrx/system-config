{ config, lib, ... }:
{
  options.features.cpp.enable = lib.mkEnableOption "C/C++ tooling with clangd and Meson formatting";

  config = lib.mkIf config.features.cpp.enable {
    outputs.homeManager = import ./home.nix;

    # The editor consumes this only when selected in this same profile.
    features.neovim.lspConfig = ''
      vim.lsp.enable('clangd')

      vim.lsp.config('efm', {
        filetypes = { "meson" },
        init_options = {
          documentFormatting = true;
        },
        settings = {
          languages = {
            meson = {
              formatCommand = "meson format";
            }
          }
        },
      })
      vim.lsp.enable('efm')
    '';
  };
}
