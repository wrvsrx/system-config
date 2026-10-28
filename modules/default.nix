{ lib, ... }:
{
  options.system-config.profiles = lib.mkOption {
    default = { };
    description = "Independent feature configurations producing NixOS and Home Manager modules.";
    type = lib.types.attrsOf (
      lib.types.submoduleWith {
        class = "system-config-profile";
        modules = [ ./profile.nix ];
        shorthandOnlyDefinesConfig = false;
      }
    );
  };
}
