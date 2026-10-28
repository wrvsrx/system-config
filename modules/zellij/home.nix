{
  programs.zellij = {
    enable = true;
    settings.mouse_mode = true;
    extraConfig = builtins.readFile ./keybinds.kdl;
  };
}
