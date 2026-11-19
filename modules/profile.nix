{ lib, ... }:
{
  _class = "system-config-profile";
  imports = [
    ./neovim/default.nix
    ./rust/default.nix
    ./zellij/default.nix
    ./cpp/default.nix
    ./haskell/default.nix
    ./json/default.nix
    ./latex/default.nix
    ./lua/default.nix
    ./nix/default.nix
    ./plumb/default.nix
    ./python/default.nix
  ];

  options.outputs = {
    nixos = lib.mkOption {
      type = lib.types.deferredModule;
      default = { };
      description = "Import into a host's NixOS configuration.";
    };
    homeManager = lib.mkOption {
      type = lib.types.deferredModule;
      default = { };
      description = "Import into a user's Home Manager configuration.";
    };
  };
}
