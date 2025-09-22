{ inputs, ... }:
{
    imports = [
        "${inputs.impermanence}/home-manager.nix"
    ];

    home.persistence."/nix/persist/home/jane" = {
      directories = [ ".ssh" "Downloads" ];
      files = [ ".bash_history" ];
    };
}
