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
      ];
      
      # Environment setup
      shellHook = ''
        echo "NixOS Live ISO development environment loaded!"
        echo "Available packages: tree, gh, git, gnome-extension-manager, gnome-tweaks, dconf-editor"
        
        # Create any necessary directories
        mkdir -p $HOME/.config
        
        # Set NIX_CONFIG for this shell session
        export NIX_CONFIG="experimental-features = nix-command flakes"
      '';
    };
    
    # Expose all your individual configuration files as NixOS modules
    nixosModules = {
      fonts-ime = import ./fonts-ime.nix;
      zsh = import ./zsh.nix;
      ghostty = import ./ghostty.nix;
    };
  };
}
