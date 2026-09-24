# system-config

Personal Home Manager configuration, shared by my NixOS and standalone Home Manager environments. No secrets are included.

## Neovim

Import `inputs.system-config.homeManagerModules.neovim` into Home Manager. The module enables Neovim by default; when `my_config.common.minimal` exists, its default is the inverse of that value. Override `my_config.neovim.enable` as needed. Language modules can append Lua through `my_config.neovim.lspConfig`.

The importing configuration supplies `pkgs`. This configuration currently uses my patched nixpkgs and public `nur-packages` overlay; it is not intended to work with arbitrary stock nixpkgs. In particular, the Treesitter configuration includes Plumb and Djot grammars. This flake exports the prepared package set as `legacyPackages.x86_64-linux`; importing the module elsewhere still uses the caller's package set.

The shared option definitions are aggregated in `modules/options.nix`; this module declares options only, without configuring system services. NixOS and Home Manager still have separate option values. For NixOS configurations that also use these options at the system level, import `inputs.system-config.nixosModules.nixos-options` into NixOS and the Home Manager module into `home-manager.sharedModules`.

Plugin settings, keybindings, and Lua configuration are preserved from `sync`. Language-specific modules remain there for now. Sidekick expects `codex-wrapper` and Zellij on PATH; Pandoc conversion expects Pandoc. Those integrations require the corresponding tools from the consuming environment. The archived commit prompt and snippets are retained as files without adding new activation behavior.

During local migration testing, `sync` uses `path:/home/wrvsrx/Documents/system-config`. After editing this repository, run `nix flake update system-config` in `sync` before rebuilding to refresh the local input snapshot. After testing and publishing, replace that URL with `github:wrvsrx/system-config` and update only that input.

## Standalone Home Manager

Keep machine-specific Home Manager configurations on each server. This repository does not define host profiles or user identities. Its public inputs provide Home Manager and the patched package set without depending on `sync`.

For example, a server's own `flake.nix` can contain:

```nix
{
  inputs.system-config.url = "github:wrvsrx/system-config";

  outputs = { system-config, ... }: {
    homeConfigurations.server =
      system-config.inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = system-config.legacyPackages.x86_64-linux;
        modules = [
          system-config.homeManagerModules.neovim
          ./home.nix
        ];
      };
  };
}
```

Set `home.username`, `home.homeDirectory`, and `home.stateVersion` in the server's `home.nix`. On non-NixOS Linux, also enable `targets.genericLinux.enable`. Configure language servers and extra tools there as needed. Keep `home.stateVersion` unchanged during routine updates.

With Home Manager installed, run `home-manager switch --flake .#server` from that server configuration directory, as the target user without sudo. This flake also exports the Home Manager CLI as `packages.x86_64-linux.home-manager`.

No SOPS, synchronization credentials, or private repository inputs are required. Codex and language-specific modules have not been migrated yet.
