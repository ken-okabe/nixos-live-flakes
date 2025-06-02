# nixos-live-flakes/ghostty.nix
{ config, pkgs, ... }:

let
  ghosttyConfigContent = ''
    # --- Ghostty Terminal Configuration ---
    font-size = 12
    background-opacity = 0.9
    split-divider-color = "green"
    gtk-titlebar = true
    
    keybind = [
      "ctrl+c=copy_to_clipboard"
      "ctrl+shift+c=copy_to_clipboard"
      "ctrl+shift+v=paste_from_clipboard"
      "ctrl+v=paste_from_clipboard"
      "ctrl+left=goto_split:left"
      "ctrl+down=goto_split:down"
      "ctrl+up=goto_split:up"
      "ctrl+right=goto_split:right"
      "ctrl+enter=new_split:down"
    ]
    clearDefaultKeybinds = false
    enableZshIntegration = true
  '';
in
{
  environment.systemPackages = [
    pkgs.ghostty
  ];

  environment.etc."xdg/ghostty/config".text = ghosttyConfigContent;
}