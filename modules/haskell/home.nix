{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (haskellPackages.ghcWithPackages (
      ps: with ps; [
        regex-tdfa
        aeson
        cassava
        graphviz
        pandoc
        pandoc-cli
        pandoc-crossref
        shake
        unicode-show
        raw-strings-qq
      ]
    ))
    haskellPackages.haskell-language-server
  ];
  xdg.configFile."cabal/config".source = pkgs.replaceVars ./cabal_config {
    inherit (config.xdg)
      dataHome
      cacheHome
      ;
  };
}
