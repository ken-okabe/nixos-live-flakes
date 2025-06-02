# nixos-live-flakes/fonts-ime.nix
#
# Configures the Input Method Editor (IME) for Japanese input (Fcitx5 + Mozc)
# and installs system-wide fonts.
{ pkgs, lib, ... }: {

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    nerd-fonts.fira-code
  ];

  fonts.fontconfig.enable = true;

  fonts.fontconfig.defaultFonts = {
    serif = [ "Liberation Serif" "Noto Serif" ];
    sansSerif = [ "Liberation Sans" "Noto Sans" ];
    monospace = [ "FiraCode Nerd Font Mono" "Noto Sans Mono" ];
    emoji = [ "Noto Color Emoji" ];
  };

  # Japanese Input Method Editor (fcitx5 with Mozc)
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc-ut
      fcitx5-gtk
      fcitx5-nord
    ];
  };

  # Environment variables for Fcitx5 IME integration
  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };
}