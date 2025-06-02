 

## Your `nixos-live-flakes` Repository Structure

```
nixos-live-flakes/
├── flake.nix
├── fonts-ime.nix
├── zsh.nix
└── ghostty.nix

```

----------

## File Contents

### 1. `nixos-live-flakes/flake.nix`

Nix

```
# nixos-live-flakes/flake.nix
{
  description = "NixOS Live ISO configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    # This 'default' NixOS module combines all your desired configurations.
    # It will be imported by /etc/nixos/configuration.nix on the Live ISO.
    nixosModules.default = { config, pkgs, lib, ... }: {
      # Import all your specific configuration modules directly
      imports = [
        ./fonts-ime.nix
        ./zsh.nix
        ./ghostty.nix
        # If you later decide to include key-remap.nix, you would add it here:
        # ./key-remap.nix
      ];

      # Add packages that don't need dedicated configuration files
      environment.systemPackages = with pkgs; [
        tree
        gh
        git
      ];

      # Set Zsh as the default shell for the 'nixos' user on the Live ISO
      users.users.nixos = {
        shell = pkgs.zsh;
      };

      # Enable flakes and nix-command for rebuilds on the Live ISO
      nix.extraOptions = ''
        experimental-features = nix-command flakes
      '';
      nix.settings.allowed-uris = [ "https://github.com/NixOS/nixpkgs/archive/" ];
    };
  };
}

```

----------

### 2. `nixos-live-flakes/fonts-ime.nix`

**The specified font packages have been removed from this file.**

Nix

```
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

```

----------

### 3. `nixos-live-flakes/zsh.nix`

Nix

```
# nixos-live-flakes/zsh.nix
{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    shellAliases = {
      ll = "ls -la -F --color=auto --group-directories-first";
      grep = "grep --color=auto";
      update-system = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
    };
    
    initExtra = ''
      # --- Powerlevel10k Theme ---
      if [ -f "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme" ]; then
        source "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
      fi
      
      # --- Zsh History Substring Search ---
      local history_substring_search_path="${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
      if [ -f "$history_substring_search_path" ]; then
        source "$history_substring_search_path"
        bindkey "$terminfo[kcuu1]" history-substring-search-up
        bindkey "$terminfo[kcud1]" history-substring-search-down
      else
        echo "Warning: zsh-history-substring-search plugin not found." >&2
      fi

      # --- Powerline/Git Prompt Setup ---
      PROMPT='%B%F{cyan}%n@%m%f:%B%F{blue}%~%f%b $(git_prompt_info)%F{normal}> %f'
    '';
  };

  environment.systemPackages = with pkgs; [
    zsh
    zsh-history-substring-search
    zsh-powerlevel10k
  ];

  environment.sessionVariables = {
    EDITOR = "nano";
  };
}

```

----------

### 4. `nixos-live-flakes/ghostty.nix`

Nix

```
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

```

----------

### Instructions for NixOS Live ISO with `nixos-rebuild switch`:

This process correctly applies your configuration via `nixos-rebuild switch`.

1.  **Prepare your `nixos-live-flakes` directory** on your local machine with these four files.
    
2.  **Clone your repository** to your `/home/nixos/` directory on the Live ISO.
    
    Bash
    
    ```
    git clone https://github.com/your-username/nixos-live-flakes.git /home/nixos/nixos-live-flakes
    
    ```
    
3.  Modify the Live ISO's configuration.nix file:
    
    Open /etc/nixos/configuration.nix using sudo and a text editor:
    
    Bash
    
    ```
    sudo nano /etc/nixos/configuration.nix
    
    ```
    
    Inside this file, locate the `imports = [ ... ];` section. **Add a line to import your flake's default module.** It should look like this:
    
    Nix
    
```
{ config, pkgs, ... }:

let
  # Define the path to your cloned flake
  myLiveFlake = (builtins.getFlake "/home/nixos/nixos-live-flakes");
in

{
  imports = [ <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-combined.nix> 

              myLiveFlake.nixosModules.default
];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
}

```
    
    **Important:** Do **not** remove or replace the existing `imports` lines. Just add `myLiveFlake.nixosModules.default` to the list. Save and exit the editor.
    
4.  **Run `nixos-rebuild switch`:**
    
    Bash
    
    ```
    sudo nixos-rebuild switch    
    ```
    sudo nix-channel --add https://nixos.org/channels/nixos-25.05 nixos
    sudo nix-channel --update

    sudo NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch

After this command completes, your Live ISO's environment should update to reflect your configurations. For Zsh and other shell-related changes, you'll need to log out and back in to the `nixos` user, or simply open a new terminal session, for them to take full effect.
