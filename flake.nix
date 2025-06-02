# nixos-live-flakes/flake.nix
{
  description = "NixOS Live ISO configuration flake";

  inputs = {
         nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # same as liveNixOS 
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
        ./key-remap.nix
      ];

      # Add packages that don't need dedicated configuration files
      environment.systemPackages = with pkgs; [
        tree
        gh
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
