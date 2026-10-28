{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    cargo
    rustc
    rust-analyzer
    sccache
  ];

  # The agent skill disables incremental compilation per Cargo invocation in
  # linked worktrees so eligible rustc invocations can use this shared cache.
  home.sessionVariables = {
    RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";
    SCCACHE_DIR = "${config.xdg.cacheHome}/sccache";
    SCCACHE_CACHE_SIZE = "20G";
  };

  home.file = builtins.listToAttrs (
    map
      (agent: {
        name = ".${agent}/skills/rust-worktree-sccache";
        value.source = ./skills/rust-worktree-sccache;
      })
      [
        "codex"
        "claude"
        "dsh"
      ]
  );

}
