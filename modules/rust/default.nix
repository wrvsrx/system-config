{ config, lib, ... }:
{
  options.features.rust.enable = lib.mkEnableOption "the Rust toolchain, sccache, and agent worktree guidance";

  config = lib.mkIf config.features.rust.enable {
    outputs.homeManager = import ./home.nix;

    # The editor consumes this only when selected in this same profile.
    features.neovim.lspConfig = ''
      vim.lsp.enable('rust_analyzer')
    '';
  };
}
