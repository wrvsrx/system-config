{ lib, ... }:
{
  _class = "system-config-profile";
  imports = [
    ./neovim/default.nix
    ./rust/default.nix
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
