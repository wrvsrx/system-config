{ lib, ... }:
{
  options.my_config.neovim.lspConfig = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "Additional Lua configuration for language servers.";
  };
}
