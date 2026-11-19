{ config, lib, ... }:
{
  options.features.plumb.enable = lib.mkEnableOption "the plumb toolchain, its agent skill, and editor integration";

  config = lib.mkIf config.features.plumb.enable {
    # The Neovim plugin is installed only when the editor is selected in this
    # same profile. Reading its enable selects a definition, not an import.
    outputs.homeManager = import ./home.nix { editor = config.features.neovim.enable; };

    features.neovim.lspConfig = ''
      require('plumb').setup({
        codelens = { picker = 'snacks' },
        search = { picker = 'snacks' },
      })
    '';
  };
}
