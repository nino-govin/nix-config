{
  description = "Configuration NixOS — nino-nixos";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url    = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs        = true;
            useUserPackages      = true;
            backupFileExtension  = "backup";  # évite les erreurs si un fichier géré existe déjà
            users.nino-nixos = import ./home/default.nix;
          };
        }
      ];
    };
  };
}
