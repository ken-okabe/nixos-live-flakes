{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Move your shell configuration here instead of initExtra
  environment.interactiveShellInit = ''
    # --- Zsh Basic Configuration ---
    export EDITOR=nano
    stty intr ^T
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
      bindkey "$terminfo[kcuu1]" history-substring-search-up
      bindkey "$terminfo[kcud1]" history-substring-search-down
    else
      echo "Warning: zsh-history-substring-search plugin not found." >&2
    fi
    
    # --- Powerline/Git Prompt Setup ---
    PROMPT='%B%F{cyan}%n@%m%f:%B%F{blue}%~%f%b $(git_prompt_info)%F{normal}> %f'
  '';

  environment.systemPackages = with pkgs; [
    zsh
    zsh-history-substring-search
    zsh-powerlevel10k
  ];
  
  environment.sessionVariables = {
    EDITOR = "nano";
  };
}
