# system-config

A typed feature configuration layer hosted by flake-parts. Each independent profile takes a feature attrset and produces NixOS and Home Manager modules. No secrets, user identities, or machine hardware are included.

## Configure a profile and consume its outputs

```nix
outputs = inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; }
    ({ config, ... }: {
      imports = [ inputs.system-config.flakeModules.default ];
      systems = [ "x86_64-linux" ];

      system-config.profiles = {
        development.features = {
          neovim.enable = true;
          rust.enable = true;
        };
        minimal = { };
      };

      flake.nixosConfigurations.example =
        let profile = config.system-config.profiles.development.outputs;
        in inputs.nixpkgs.lib.nixosSystem {
          modules = [
            ./configuration.nix
            profile.nixos
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.users.alice.imports = [
                profile.homeManager
              ];
            }
          ];
        };
    });
```

`configuration.nix` supplies the host platform, hardware, user account, package set, and state versions. The Home Manager user also needs its normal identity/state-version settings.

Importing `flakeModules.default` declares the profile container. Each named profile has its own module evaluation and defaults all features to disabled. The outputs are deferred modules, not evaluated NixOS systems or HM activation packages. Hosts consume them using `imports`; this profile layer does not automatically create users or wire HM into NixOS. Both current features contribute to HM; the NixOS output is empty until system features are added.

Profiles support normal module composition and priorities:

```nix
system-config.profiles.work = {
  imports = [ ./profiles/common-development.nix ];
  features.rust.enable = false;
};
```

The imported file can set `features.rust.enable = lib.mkDefault true`. Reuse profile module definitions across instances rather than copying evaluated outputs and trying to change their captured parameters. Modules in this layer have class `system-config-profile`, distinct from flake-parts, NixOS, and HM modules.

## Features and their integration

- `features.neovim.enable`: personal editor configuration, plugins, keybindings, and Lua assets.
- `features.neovim.lspConfig`: mergeable Lua text executed inside the nvim-lspconfig plugin configuration after common LSP setup. Contributions use standard `mkBefore`/`mkAfter` ordering within this option.
- `features.rust.enable`: Cargo, rustc, rust-analyzer, sccache, cache environment variables, and the rust-worktree-sccache skill for Codex, Claude, and dsh.

Rust contributes `vim.lsp.enable('rust_analyzer')` to the profile's Neovim extension. Neovim consumes it only when enabled in that profile. Rust alone does not enable the editor; Neovim alone does not install Rust. Neither feature reads `osConfig` or mirrors NixOS feature options into HM.

All feature definitions are loaded before evaluating feature conditions. Their contributions are guarded with `mkIf`; do not select `imports` using `config` from that same evaluation.

Packages and runtime paths are resolved inside the generated HM module using the consuming environment's `pkgs` and `config.xdg.cacheHome`. Profile Lua text is platform-independent; package-dependent future extensions should defer rendering until the target package set is available.

## Migration boundary

The former `flake.modules.homeManager.neovim` selection interface is replaced by profiles. Earlier `homeManagerModules` and `nixosModules.nixos-options` interfaces remain removed.

The Neovim implementation temporarily declares the HM option `my_config.neovim.lspConfig` for unmigrated language modules in `sync`. Its text runs after the profile-level LSP text at the same plugin configuration location. New features should use `features.neovim.lspConfig` inside profiles. Remove the bridge after the remaining languages migrate. There is no HM or NixOS Rust feature switch.

## Packages and external tools

The consuming environment must supply the patched nixpkgs and public `nur-packages` overlay, including Plumb and Djot Treesitter grammars. Selecting a feature does not replace its package set.

This flake retains `legacyPackages.x86_64-linux`, `packages.x86_64-linux.home-manager`, and `formatter.x86_64-linux`. Sidekick expects `codex-wrapper` and Zellij on PATH; Pandoc conversion expects Pandoc. These tools remain the consumer's responsibility.

## Validation

The profile tests evaluate real HM configurations for empty, Rust-only, editor-only, combined, and overridden profiles. They check isolation, extension ordering and placement, target paths, and skill installation without building or activating a system:

```sh
nix eval --impure --json --expr '
  let f = builtins.getFlake (toString ./.);
  in import ./tests/profiles.nix {
    lib = f.inputs.nixpkgs.lib;
    pkgs = f.legacyPackages.x86_64-linux;
    home-manager = f.inputs.home-manager;
  }'
```

## Integration with sync

`sync` imports `github:wrvsrx/system-config`, selects `development` for its four daily configurations and an empty `minimal` profile for the server and ISOs. Publish changes here first, then run `nix flake update system-config` in `sync`.

For local development, temporarily override the input with `path:/home/wrvsrx/Documents/system-config`. Restore the GitHub reference and update that input after publishing.
