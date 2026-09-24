# system-config

Personal Home Manager configuration, shared by my NixOS and standalone Home Manager environments. No secrets are included.

## Neovim

Import `inputs.system-config.homeManagerModules.neovim` into Home Manager. The module enables Neovim by default; when `my_config.common.minimal` exists, its default is the inverse of that value. Override `my_config.neovim.enable` as needed. Language modules can append Lua through `my_config.neovim.lspConfig`.

The importing configuration supplies `pkgs`. This configuration currently uses my patched nixpkgs and personal overlays from `sync`; it is not intended to work with arbitrary stock nixpkgs. In particular, the Treesitter configuration includes Plumb and Djot grammars. This flake only exports modules and does not install Home Manager or select a package set.

For NixOS configurations that also use the Neovim options at the system level, import `inputs.system-config.nixosModules.neovim-options` into NixOS and the Home Manager module into `home-manager.sharedModules`.

Plugin settings, keybindings, and Lua configuration are preserved from `sync`. Language-specific modules remain there for now. Sidekick expects `codex-wrapper` and Zellij on PATH; Pandoc conversion expects Pandoc. Those integrations require the corresponding tools from the consuming environment. The archived commit prompt and snippets are retained as files without adding new activation behavior.

During local migration testing, `sync` uses `path:/home/wrvsrx/Documents/system-config`. After editing this repository, run `nix flake update system-config` in `sync` before rebuilding to refresh the local input snapshot. After testing and publishing, replace that URL with `github:wrvsrx/system-config` and update only that input.
