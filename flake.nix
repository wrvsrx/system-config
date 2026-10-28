{
  description = "Personal configuration modules";

  inputs = {
    nur-wrvsrx.url = "github:wrvsrx/nur-packages";
    nixpkgs.follows = "nur-wrvsrx/nixpkgs";
    flake-parts.follows = "nur-wrvsrx/flake-parts";
    home-manager = {
      url = "github:wrvsrx/home-manager/patched-master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./modules/default.nix ];
      flake.flakeModules.default = ./modules/default.nix;

      systems = [ "x86_64-linux" ];
      perSystem = { system, pkgs, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ inputs.nur-wrvsrx.overlays.default ];
        };
        legacyPackages = pkgs;
        packages.home-manager = inputs.home-manager.packages.${system}.home-manager;
        formatter = pkgs.nixfmt;
      };
    };
}
