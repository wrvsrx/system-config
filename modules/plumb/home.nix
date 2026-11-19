{ editor }:
{ lib, pkgs, ... }:
{
  home.packages = [ pkgs.plumb ];

  # Use home.file instead of programs.<agent>.skills: Home Manager evaluates the
  # store path to determine whether a skill is a directory or inline text, which
  # triggers IFD when the skill comes from a package built by the consumer.
  home.file = builtins.listToAttrs (
    map
      (agent: {
        name = ".${agent}/skills/plumb-markup";
        value.source = "${pkgs.plumb}/share/plumb/skills/plumb-markup";
      })
      [
        "codex"
        "claude"
        "dsh"
      ]
  );

  programs.neovim.plugins = lib.mkIf editor [ pkgs.vimPlugins.plumb-nvim ];
}
