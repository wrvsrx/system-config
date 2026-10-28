# system-config

Reusable personal configuration features, loaded into the consumer's flake-parts evaluation. No secrets, host profiles, or user identities are included.

## Loading and selecting features

The consumer supplies a `flake-parts` input and imports this repository's flake module:

```nix
outputs = inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; }
    ({ config, ... }: {
      imports = [ inputs.system-config.flakeModules.default ];
      systems = [ "x86_64-linux" ];

      flake.nixosConfigurations.example = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.home-manager.nixosModules.home-manager
          ./configuration.nix
          {
            home-manager.users.alice.imports = [
              config.flake.modules.homeManager.neovim
            ];
          }
        ];
      };
    });
```

Importing `flakeModules.default` registers available features; it does not enable them on any host or user. Select features through the target configuration's `imports`. Feature dependencies can likewise use `imports` to compose values from `config.flake.modules`.

The only feature currently provided is `flake.modules.homeManager.neovim`. Importing it enables the editor. There is no custom `my_config.neovim.enable` switch and no NixOS-side mirror of its options. Language modules in the same Home Manager evaluation can append Lua through `my_config.neovim.lspConfig` (`types.lines`). Host selection and roles belong to the consumer.

The previous `homeManagerModules` and `nixosModules.nixos-options` entry points have been removed. Consumers use `flakeModules.default` and select modules from their own flake-parts configuration. A standalone Home Manager configuration can be assembled in that same top-level evaluation without any `osConfig` bridge.

## Packages and integrations

The importing configuration supplies `pkgs`. Neovim currently requires the patched nixpkgs and public `nur-packages` overlay, including Plumb and Djot Treesitter grammars. Importing the feature does not replace the consumer's package set.

This flake retains `legacyPackages.x86_64-linux`, the Home Manager CLI at `packages.x86_64-linux.home-manager`, and `formatter.x86_64-linux`, assembled using flake-parts `perSystem`.

Plugin settings, keybindings, and Lua configuration are preserved. Sidekick expects `codex-wrapper` and Zellij on PATH; Pandoc conversion expects Pandoc. Language-specific modules and those tools remain the consumer's responsibility. Archived snippets and commit prompts remain files without new activation behavior.

## Integration with sync

`sync` imports `github:wrvsrx/system-config`. Publish changes here first, then run `nix flake update system-config` in `sync` to select the published revision.

For local development, temporarily override the input with `path:/home/wrvsrx/Documents/system-config`. Restore the GitHub reference and update that input after publishing.
