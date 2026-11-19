# Evaluate with the flake's pinned lib, package set, and Home Manager library.
{
  lib,
  pkgs,
  home-manager,
}:
let
  languages = [
    "cpp"
    "haskell"
    "json"
    "latex"
    "lua"
    "nix"
    "plumb"
    "python"
  ];
  languageFeatures = lib.genAttrs languages (_: {
    enable = true;
  });
  profiles =
    (lib.evalModules {
      modules = [
        ../modules/default.nix
        {
          system-config.profiles = {
            empty = { };
            rust.features.rust.enable = true;
            editor.features.neovim.enable = true;
            development = {
              imports = [
                { features.rust.enable = lib.mkDefault true; }
                { features.neovim.lspConfig = lib.mkBefore "-- before-rust"; }
              ];
              features.neovim = {
                enable = true;
                lspConfig = lib.mkAfter "-- after-rust";
              };
            };
            languages.features = languageFeatures;
            languagesEditor.features = languageFeatures // {
              neovim.enable = true;
            };
            overridden = {
              imports = [ { features.rust.enable = lib.mkDefault true; } ];
              features.rust.enable = false;
            };
          };
        }
      ];
    }).config.system-config.profiles;

  homes = lib.mapAttrs (
    _: profile:
    (home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        profile.outputs.homeManager
        {
          home.username = "test";
          home.homeDirectory = "/home/test";
          home.stateVersion = "25.11";
          xdg.cacheHome = "/home/test/custom-cache";
        }
      ];
    }).config
  ) profiles;

  rustLua = "vim.lsp.enable('rust_analyzer')";
  lspPlugin =
    home:
    lib.findFirst (
      plugin: (plugin.plugin.pname or "") == "nvim-lspconfig"
    ) (throw "nvim-lspconfig plugin missing") home.programs.neovim.plugins;
  containsRust = home: builtins.elem pkgs.rustc home.home.packages;
  tests = {
    emptyInstallsNeither = !homes.empty.programs.neovim.enable && !containsRust homes.empty;
    rustDoesNotEnableEditor = containsRust homes.rust && !homes.rust.programs.neovim.enable;
    editorDoesNotInstallRust = homes.editor.programs.neovim.enable && !containsRust homes.editor;
    profilesAreIsolated = profiles.editor.features.neovim.lspConfig == "";
    defaultsCanBeOverridden = !containsRust homes.overridden;
    developmentEnablesBoth = containsRust homes.development && homes.development.programs.neovim.enable;
    extensionsMergeInOrder = lib.hasInfix "-- before-rust\n${rustLua}\n\n-- after-rust" profiles.development.features.neovim.lspConfig;
    extensionRunsInPlugin = lib.hasInfix rustLua (lspPlugin homes.development).config;
    editorHasNoRustExtension = !lib.hasInfix rustLua (lspPlugin homes.editor).config;
    cacheUsesTargetHome =
      homes.rust.home.sessionVariables.SCCACHE_DIR == "/home/test/custom-cache/sccache";
    wrapperUsesTargetPackages =
      homes.rust.home.sessionVariables.RUSTC_WRAPPER == "${pkgs.sccache}/bin/sccache";
    skillsPreserved =
      builtins.all
        (
          agent:
          builtins.pathExists (
            homes.rust.home.file.".${agent}/skills/rust-worktree-sccache".source + "/SKILL.md"
          )
        )
        [
          "codex"
          "claude"
          "dsh"
        ];
    noLegacyOptions = builtins.all (home: !(home ? my_config)) (builtins.attrValues homes);
    languagesDoNotEnableEditor =
      !homes.languages.programs.neovim.enable && builtins.elem pkgs.texlab homes.languages.home.packages;
    languageExtensionsRunInPlugin =
      builtins.all (lua: lib.hasInfix lua (lspPlugin homes.languagesEditor).config)
        [
          "vim.lsp.enable('clangd')"
          "vim.lsp.enable('hls')"
          "vim.lsp.enable('jsonls')"
          "vim.lsp.enable('texlab')"
          "vim.lsp.enable('lua_ls')"
          "vim.lsp.enable('nil_ls')"
          "require('plumb').setup"
          "vim.lsp.enable('basedpyright')"
        ];
    plumbPluginFollowsEditor =
      let
        hasPlumb =
          home: builtins.any (p: (p.plugin or p) == pkgs.vimPlugins.plumb-nvim) home.programs.neovim.plugins;
      in
      hasPlumb homes.languagesEditor && !hasPlumb homes.languages;
    languageFilesUseTargetHome =
      homes.languages.home.sessionVariables.PYTHONSTARTUP == "/home/test/custom-cache/python/pythonrc"
      && homes.languages.xdg.configFile ? "cabal/config"
      && builtins.all (agent: homes.languages.home.file ? ".${agent}/skills/plumb-markup") [
        "codex"
        "claude"
        "dsh"
      ];
    generatedNixosModuleWorks =
      (lib.evalModules {
        modules = [ profiles.development.outputs.nixos ];
      }).config == { };
  };
in
lib.mapAttrs (name: passed: if passed then true else throw "Profile test failed: ${name}") tests
