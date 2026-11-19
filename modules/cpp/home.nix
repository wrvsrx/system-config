{ pkgs, ... }:
{
  home.packages =
    let
      llvmPackages = pkgs.llvmPackages_18;
    in
    [
      llvmPackages.clang
      llvmPackages.clang-tools
      pkgs.gdb
    ];
}
