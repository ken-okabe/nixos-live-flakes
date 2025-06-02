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