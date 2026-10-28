# Import into the consumer's flake-parts evaluation to register features.
{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    ./neovim/default.nix
  ];
}
