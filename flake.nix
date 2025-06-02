# nixos-live-flakes/flake.nix
{
  description = "Minimal custom flake for NixOS Live ISO development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {

    devShells.x86_64-linux.default = nixpkgs.lib.mkShell { # <--- This is the attribute Nix is looking for
      # Packages that are simply installed and don't have dedicated config modules
      packages = with nixpkgs; [
        tree
        gh
        git
        
        gnome-extension-manager          
        gnome-tweaks                    
        dconf-editor          
      ];

      # Import all your specific configuration modules.
      # Their 'environment.systemPackages' and 'shellHook' options will be combined.
      modules = [
        self.fonts-ime
        self.zsh
        self.ghostty
      ];

      # No top-level shellHook here, as zsh.nix's shellHook will ultimately execute zsh.
      # Initial setup like mkdir -p will be handled by individual modules' shellHooks.

      # Ensure experimental features are enabled for this shell evaluation
      nix.extraOptions = ''
        experimental-features = nix-command flakes
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
