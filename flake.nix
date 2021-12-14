{
  description = "Emmanuel's NixOS/Nix Flakes repository.";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux = let
      callPackage = nixpkgs.legacyPackages.x86_64-linux.callPackage;
      in {
        electrum-personal-server = callPackage ./pkgs/electrum-personal-server.nix {};
        nvidia-offload = callPackage ./pkgs/nvidia-offload.nix {};
        century-gothic = callPackage ./pkgs/century-gothic {};
        wingdings = callPackage ./pkgs/wingdings.nix {};
        trace = callPackage ./pkgs/trace.nix {};
        battery-icons = callPackage ./pkgs/battery-icons.nix {};
    };

    packages.aarch64-linux = let
      callPackage = nixpkgs.legacyPackages.aarch64-linux.callPackage;
      in {
        electrum-personal-server = callPackage ./pkgs/electrum-personal-server.nix {};
        century-gothic = callPackage ./pkgs/century-gothic {};
        wingdings = callPackage ./pkgs/wingdings.nix {};
        trace = callPackage ./pkgs/trace.nix {};
        battery-icons = callPackage ./pkgs/battery-icons.nix {};
    };

    packages.i686-linux = let
      callPackage = nixpkgs.legacyPackages.i686-linux.callPackage;
      in {
        electrum-personal-server = callPackage ./pkgs/electrum-personal-server.nix {};
        century-gothic = callPackage ./pkgs/century-gothic {};
        wingdings = callPackage ./pkgs/wingdings.nix {};
        trace = callPackage ./pkgs/trace.nix {};
        battery-icons = callPackage ./pkgs/battery-icons.nix {};
    };

    nixosModules.electrum-personal-server = import ./modules/electrum-personal-server.nix;
    nixosModules.protonvpn = import ./modules/protonvpn.nix;
  };
}
