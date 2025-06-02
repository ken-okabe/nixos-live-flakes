# nixos-live-flakes/flake.nix
{
  description = "Minimal custom flake for NixOS Live ISO development environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, ... }: 
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      # Packages that are simply installed and don't have dedicated config modules
      buildInputs = with pkgs; [
        tree
        gh
        git
        
        gnome-extension-manager          
        gnome-tweaks                    
        dconf-editor
        
        # Zsh and related packages
        zsh
        zsh-history-substring-search
        zsh-powerlevel10k
        zsh-autosuggestions
        zsh-syntax-highlighting
        
        # Terminal
        ghostty
        
        # Fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        liberation_ttf
        fira-code
        nerd-fonts.fira-code
        
        # Japanese Input Method Editor (Fcitx5 + Mozc)
        fcitx5
        fcitx5-mozc-ut
        fcitx5-gtk
        fcitx5-nord
        fcitx5-configtool
      ];
      
      # Environment setup
      shellHook = ''
        echo "NixOS Live ISO development environment loaded!"
        echo "Available packages: tree, gh, git, gnome-extension-manager, gnome-tweaks, dconf-editor, ghostty"
        echo "Fonts: Noto fonts, Liberation fonts, FiraCode Nerd Font"
        echo "Japanese IME: Fcitx5 + Mozc available"
        echo "Zsh with Powerlevel10k theme available"
        
        # Create any necessary directories
        mkdir -p $HOME/.config
        
        # Set NIX_CONFIG for this shell session
        export NIX_CONFIG="experimental-features = nix-command flakes"
        
        # --- Ghostty Terminal Configuration ---
        echo "Setting up Ghostty configuration..."
        mkdir -p $HOME/.config/ghostty
        
        cat > $HOME/.config/ghostty/config << 'EOF'
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
EOF
        
        echo "Ghostty config created at: $HOME/.config/ghostty/config"
        
        # --- Fcitx5 Setup ---
        echo "Setting up Fcitx5 for Japanese input..."
        mkdir -p $HOME/.config/fcitx5
        
        # Create basic fcitx5 profile
        cat > $HOME/.config/fcitx5/profile << 'EOF'
[Groups/0]
# Group Name
Name=Default
# Layout
Default Layout=us
# Default Input Method
DefaultIM=mozc

[Groups/0/Items/0]
# Name
Name=keyboard-us
# Layout
Layout=

[Groups/0/Items/1]
# Name
Name=mozc
# Layout
Layout=

[GroupOrder]
0=Default
EOF
        
        # Create fcitx5 config
        cat > $HOME/.config/fcitx5/config << 'EOF'
[Hotkey]
# Enumerate when press trigger key repeatedly
EnumerateWithTriggerKeys=True
# Temporally switch between first and current Input Method
AltTriggerKeys=
# Enumerate Input Method Forward
EnumerateForwardKeys=
# Enumerate Input Method Backward
EnumerateBackwardKeys=
# Skip first input method while enumerating
EnumerateSkipFirst=False

[Hotkey/TriggerKeys]
0=Control+space
1=Zenkaku_Hankaku

[Hotkey/EnumerateGroupForwardKeys]
0=Super+space

[Hotkey/EnumerateGroupBackwardKeys]
0=Shift+Super+space

[Hotkey/ActivateKeys]
0=Hangul_Hanja

[Hotkey/DeactivateKeys]
0=Hangul_Romaja

[Behavior]
# Active By Default
ActiveByDefault=False
# Share Input State
ShareInputState=No
# Show preedit in application
PreeditEnabledByDefault=True
# Show Input Method Information when switch input method
ShowInputMethodInformation=True
# Show Input Method Information when changing focus
ShowInputMethodInformationWhenFocusIn=False
# Show compact input method information
CompactInputMethodInformation=True
# Show first input method information
ShowFirstInputMethodInformation=True
# Default page size
DefaultPageSize=5
# Override Xkb Option
OverrideXkbOption=False
# Custom Xkb Option
CustomXkbOption=
# Force Enabled Addons
EnabledAddons=
# Force Disabled Addons
DisabledAddons=
# Preload input method to be used by default
PreloadInputMethod=True
# Allow input method in the password field
AllowInputMethodForPassword=False
# Show preedit text when typing password
ShowPreeditForPassword=False
# Interval of saving user data in minutes
AutoSavePeriod=30
EOF
        
        echo "Fcitx5 configuration created"
        echo ""
        echo "To start Fcitx5 for Japanese input:"
        echo "  fcitx5 &"
        echo ""
        echo "Toggle Japanese input with: Ctrl+Space or Zenkaku/Hankaku key"
        
        # --- Zsh Configuration ---
        export EDITOR=nano
        export SHELL=${pkgs.zsh}/bin/zsh
        
        # --- Fcitx5 IME Environment Variables ---
        export GTK_IM_MODULE=fcitx
        export QT_IM_MODULE=fcitx
        export XMODIFIERS="@im=fcitx"
        
        # --- Font Configuration ---
        # Create fontconfig directory and configuration
        mkdir -p $HOME/.config/fontconfig
        
        cat > $HOME/.config/fontconfig/fonts.conf << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <!-- Default fonts -->
  <alias>
    <family>serif</family>
    <prefer>
      <family>Liberation Serif</family>
      <family>Noto Serif</family>
    </prefer>
  </alias>
  
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Liberation Sans</family>
      <family>Noto Sans</family>
    </prefer>
  </alias>
  
  <alias>
    <family>monospace</family>
    <prefer>
      <family>FiraCode Nerd Font Mono</family>
      <family>Noto Sans Mono</family>
    </prefer>
  </alias>
  
  <alias>
    <family>emoji</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
</fontconfig>
EOF
        
        echo "Font configuration created at: $HOME/.config/fontconfig/fonts.conf"
        
        # Set up zsh configuration directory
        mkdir -p $HOME/.config/zsh
        
        # Create a temporary zshrc for this development shell
        cat > $HOME/.config/zsh/dev-shell-zshrc << 'EOF'
# --- Zsh Basic Configuration ---
export EDITOR=nano
stty intr ^T 2>/dev/null || true  # Ignore error if not in terminal
setopt autocd

# Define aliases
alias ll='ls -la -F --color=auto --group-directories-first'
alias grep='grep --color=auto'
alias update-system='sudo nixos-rebuild switch --flake /etc/nixos#nixos'

# --- Powerlevel10k Theme ---
if [ -f "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme" ]; then
  source "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
fi

# --- Zsh History Substring Search ---
local history_substring_search_path="${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
if [ -f "$history_substring_search_path" ]; then
  source "$history_substring_search_path"
  bindkey "^[[A" history-substring-search-up
  bindkey "^[[B" history-substring-search-down
else
  echo "Warning: zsh-history-substring-search plugin not found." >&2
fi

# --- Basic Git Prompt Function ---
git_prompt_info() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    local branch=$(git branch --show-current 2>/dev/null || echo "detached")
    echo "%F{yellow}($branch)%f"
  fi
}

# --- Custom Prompt ---
PROMPT='%B%F{cyan}%n@%m%f:%B%F{blue}%~%f%b $(git_prompt_info)%F{normal}> %f'

# Enable zsh features
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_STORE
setopt HIST_EXPAND

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$HOME/.zsh_history

# Enable completion system
autoload -Uz compinit
compinit

# Enable auto-suggestions and syntax highlighting if available
if [ -f "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [ -f "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
EOF

        echo ""
        echo "To use zsh with the custom configuration, run:"
        echo "  zsh --rcs -c 'source \$HOME/.config/zsh/dev-shell-zshrc; zsh'"
        echo ""
        echo "Or simply run 'zsh' and then source the config manually:"
        echo "  source \$HOME/.config/zsh/dev-shell-zshrc"
      '';
    };
    

  };
}
