{ lib, ... }:
{
  options.my_config.neovim.lspConfig = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "Migration bridge for HM language modules not yet moved into system-config profiles.";
  };
}
