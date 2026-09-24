{ config, lib, ... }:
{
  options.my_config.neovim = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = !(config.my_config.common.minimal or false);
      description = "Enable my Neovim configuration.";
    };
    lspConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional Lua configuration for language servers.";
    };
  };
}
