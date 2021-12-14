{
  description = "Emmanuel's NixOS/Nix Flakes repository.";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux = let
      callPackage = nixpkgs.legacyPackages.x86_64-linux.callPackage;
      hsCallPackage = nixpkgs.legacyPackages.x86_64-linux.haskellPackages.callPackage;
      in {
        electrum-personal-server = callPackage ./pkgs/electrum-personal-server.nix {};
        nvidia-offload = callPackage ./pkgs/nvidia-offload.nix {};
        century-gothic = callPackage ./pkgs/century-gothic {};
        wingdings = callPackage ./pkgs/wingdings.nix {};
        trace = callPackage ./pkgs/trace.nix {};
        battery-icons = callPackage ./pkgs/battery-icons.nix {};
        er-wallpaper = hsCallPackage ./pkgs/er-wallpaper.nix { };
        pdf2png = callPackage ./pkgs/pdf2png.nix {};
        rofi-menu = callPackage ./pkgs/rofi-menu.nix {};
        bitcoin-onion-nodes = callPackage ./pkgs/bitcoin-onion-nodes.nix {};
        sparrow = callPackage ./pkgs/sparrow.nix {};
        muun-recovery-tool = callPackage ./pkgs/muun-recovery-tool.nix {};
        tastyworks = callPackage ./pkgs/tastyworks.nix {};
    };

    packages.aarch64-linux = let
      callPackage = nixpkgs.legacyPackages.aarch64-linux.callPackage;
      hsCallPackage = nixpkgs.legacyPackages.x86_64-linux.haskellPackages.callPackage;
      in {
        electrum-personal-server = callPackage ./pkgs/electrum-personal-server.nix {};
        century-gothic = callPackage ./pkgs/century-gothic {};
        wingdings = callPackage ./pkgs/wingdings.nix {};
        trace = callPackage ./pkgs/trace.nix {};
        battery-icons = callPackage ./pkgs/battery-icons.nix {};
        er-wallpaper = hsCallPackage ./pkgs/er-wallpaper.nix { };
        pdf2png = callPackage ./pkgs/pdf2png.nix {};
        rofi-menu = callPackage ./pkgs/rofi-menu.nix {};
        bitcoin-onion-nodes = callPackage ./pkgs/bitcoin-onion-nodes.nix {};
    };

    packages.i686-linux = let
      callPackage = nixpkgs.legacyPackages.i686-linux.callPackage;
      hsCallPackage = nixpkgs.legacyPackages.x86_64-linux.haskellPackages.callPackage;
      in {
        electrum-personal-server = callPackage ./pkgs/electrum-personal-server.nix {};
        century-gothic = callPackage ./pkgs/century-gothic {};
        wingdings = callPackage ./pkgs/wingdings.nix {};
        trace = callPackage ./pkgs/trace.nix {};
        battery-icons = callPackage ./pkgs/battery-icons.nix {};
        er-wallpaper = hsCallPackage ./pkgs/er-wallpaper.nix { };
        pdf2png = callPackage ./pkgs/pdf2png.nix {};
        rofi-menu = callPackage ./pkgs/rofi-menu.nix {};
        bitcoin-onion-nodes = callPackage ./pkgs/bitcoin-onion-nodes.nix {};
        muun-recovery-tool = callPackage ./pkgs/muun-recovery-tool.nix {};
    };

    nixosModules.electrum-personal-server = import ./modules/electrum-personal-server.nix;
    nixosModules.protonvpn = import ./modules/protonvpn.nix;
  };
}
