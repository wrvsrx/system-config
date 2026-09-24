{
  description = "Personal Home Manager configuration";

  inputs = {
    nur-wrvsrx.url = "github:wrvsrx/nur-packages";
    nixpkgs.follows = "nur-wrvsrx/nixpkgs";
    home-manager = {
      url = "github:wrvsrx/home-manager/patched-master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nur-wrvsrx,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ nur-wrvsrx.overlays.default ];
      };
    in
    {
      homeManagerModules = {
        neovim = ./modules/neovim/home.nix;
        default = self.homeManagerModules.neovim;
      };
      nixosModules.neovim-options = ./modules/neovim/options.nix;

      legacyPackages.${system} = pkgs;

      packages.${system}.home-manager = home-manager.packages.${system}.home-manager;
      formatter.${system} = pkgs.nixfmt;
    };
}
