# nixos-live-flakes/flake.nix
{
  description = "Consolidated NixOS Live ISO custom environment flake";

  inputs = {
    # It is recommended to pin nixpkgs to a specific commit hash for stability.
    # Replacing 'nixos-unstable' with a hash like 'f20485a3c945b08e2f0732890539c32f81152a55'
    # can prevent issues if 'nixos-unstable' is temporarily broken.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      # Define pkgs for this system
      pkgs = nixpkgs.legacyPackages.${system};

      # --- Define Zshrc Content ---
      # This content will be written to ~/.config/zsh/dev-shell-zshrc
      devShellZshrcContent = ''
        # --- Zsh Basic Configuration ---
        export EDITOR=nano
        stty intr ^T 2>/dev/null || true # Ignore error if not in terminal
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
      '';

      # --- Define Ghostty Config Content ---
      ghosttyConfigContent = ''
        font-size = 12
        background-opacity = 0.9
        split-divider-color = "green"
        gtk-titlebar = true
        
        # Use zsh with custom configuration as default shell
        shell-integration = zsh
        command = zsh --rcs -c "source $HOME/.config/zsh/dev-shell-zshrc; exec zsh"

        keybind = ctrl+c=copy_to_clipboard
        keybind = ctrl+shift+c=copy_to_clipboard
        keybind = ctrl+shift+v=paste_from_clipboard
        keybind = ctrl+v=paste_from_clipboard
        keybind = ctrl+left=goto_split:left
        keybind = ctrl+down=goto_split:down
        keybind = ctrl+up=goto_split:up
        keybind = ctrl+right=goto_split:right
        keybind = ctrl+enter=new_split:down
      '';
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        # All packages required for your environment
        buildInputs = with pkgs; [
          tree
          gh
          git
          zsh
          zsh-history-substring-search
          zsh-powerlevel10k
          zsh-autosuggestions
          zsh-syntax-highlighting
          ghostty
          # Fonts and IME packages
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-emoji
          liberation_ttf
          fira-code
          nerd-fonts.fira-code
          fcitx5
          fcitx5-mozc
          fcitx5-gtk
          fcitx5-nord
          fcitx5-configtool
          gnome-extension-manager
          gnome-tweaks
          dconf-editor
        ];

        # This shellHook combines all setup logic from previous modules
        shellHook = ''
          echo "NixOS Live ISO development environment loaded!"
          echo "Setting up custom directories and configurations..."

          # --- Create necessary directories ---
          mkdir -p "$HOME/.config/ghostty" "$HOME/.config/zsh" "$HOME/.config/fontconfig" "$HOME/.config/fcitx5"

          # --- Font Configuration ---
          # This writes the fontconfig preferences to the user's ephemeral home directory
          cat > "$HOME/.config/fontconfig/fonts.conf" << 'EOF_FONTCONF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
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
EOF_FONTCONF
          echo "Font configuration created at: $HOME/.config/fontconfig/fonts.conf"

          # --- Fcitx5 IME Environment Variables ---
          # These need to be exported in the shell
          export GTK_IM_MODULE=fcitx
          export QT_IM_MODULE=fcitx
          export XMODIFIERS="@im=fcitx"
          # Set locale for IME
          export LC_ALL="ja_JP.UTF-8"
          export LANG="ja_JP.UTF-8"
          export LANGUAGE="ja_JP.UTF-8"

          # --- Fcitx5 config files ---
          cat > "$HOME/.config/fcitx5/profile" << 'EOF_FCITX_PROF'
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=mozc

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=mozc
Layout=

[GroupOrder]
0=Default
EOF_FCITX_PROF
          
          cat > "$HOME/.config/fcitx5/config" << 'EOF_FCITX_CONF'
[Hotkey]
EnumerateWithTriggerKeys=True
AltTriggerKeys=
EnumerateForwardKeys=
EnumerateBackwardKeys=
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
ActiveByDefault=False
ShareInputState=No
PreeditEnabledByDefault=True
ShowInputMethodInformation=True
ShowInputMethodInformationWhenFocusIn=False
ShowCompactInputMethodInformation=True
ShowFirstInputMethodInformation=True
DefaultPageSize=5
OverrideXkbOption=False
CustomXkbOption=
ForceEnabledAddons=
ForceDisabledAddons=
PreloadInputMethod=True
AllowInputMethodForPassword=False
ShowPreeditForPassword=False
AutoSavePeriod=30
EOF_FCITX_CONF
          echo "Fcitx5 configuration files created at $HOME/.config/fcitx5/"

          # --- Zsh Configuration ---
          # This writes the zshrc content to the user's home directory for Ghostty to source
          cat > "$HOME/.config/zsh/dev-shell-zshrc" << 'EOF_ZSHRC'
${devShellZshrcContent}
EOF_ZSHRC
          echo "Zsh configuration created at: $HOME/.config/zsh/dev-shell-zshrc"

          # --- Ghostty Configuration ---
          # This writes Ghostty's config file
          cat > "$HOME/.config/ghostty/config" << 'EOF_GHOSTTY_CONF'
${ghosttyConfigContent}
EOF_GHOSTTY_CONF
          echo "Ghostty configuration created at: $HOME/.config/ghostty/config"

          echo ""
          echo "Launching Ghostty terminal with configured zsh..."
          echo "Ghostty will start with your custom zsh configuration automatically."
          echo ""
          
          # --- Automatic Ghostty Launch ---
          # This will launch Ghostty, replacing the current terminal session.
          # Ghostty will then automatically source your custom Zsh configuration.
          exec ${pkgs.ghostty}/bin/ghostty
        '';
      };
    };
}
