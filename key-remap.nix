# /templates/key-remap.nix
{ config, pkgs, lib, inputs, nixosUsername, ... }: # nixosUsername is already an argument
let
  username = nixosUsername; # Uses the argument
in
{

  services.keyd.enable = true;
  services.keyd.keyboards = {
    default = {
      ids = [ "*" ];
      settings.main = { capslock = "leftcontrol"; };
    };
    "Magic Keyboard" = {
      ids = [ "004c:029c" ];
      settings.main = {
        capslock = "leftcontrol";
        rightmeta = "S-f1";
        fn = "S-f2";
      };
    };
  };
}
