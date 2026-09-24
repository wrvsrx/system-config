{
  description = "Personal Home Manager configuration";

  outputs = { self }: {
    homeManagerModules = {
      neovim = ./modules/neovim/home.nix;
      default = self.homeManagerModules.neovim;
    };
    nixosModules.neovim-options = ./modules/neovim/options.nix;
  };
}
