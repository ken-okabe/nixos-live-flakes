{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;            # Add this
    autosuggestions.enable = true;      # Fixed: was "autosuggestion"
    syntaxHighlighting.enable = true;   # This is correct
    
    # You can actually use shellAliases directly in NixOS
    shellAliases = {
      ll = "ls -la -F --color=auto --group-directories-first";
      grep = "grep --color=auto";
      update-system = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
    };
    
    initExtra = ''
      # --- Zsh Basic Configuration ---
      export EDITOR=nano
      stty intr ^T
      setopt autocd
      
      # --- Powerlevel10k Theme ---
      if [ -f "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme" ]; then
        source "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
      fi
      
      # --- Rest of your config ---
      # ... (keep the rest as is)
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
