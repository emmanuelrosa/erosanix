{
  description = "Emmanuel's NixOS/Nix Flakes repository.";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux = let
      pkgs = import "${nixpkgs}" {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
      hsCallPackage = pkgs.haskellPackages.callPackage;
      mkWindowsApp = callPackage ./pkgs/mkWindowsApp.nix { makeBinPath = pkgs.lib.makeBinPath; };
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

        notepad-plus-plus = callPackage ./pkgs/notepad++.nix { 
          inherit mkWindowsApp;
          wine = pkgs.wineWowPackages.full; 
          wineArch = "win64";
        };

        sierrachart = callPackage ./pkgs/sierrachart.nix { 
          inherit mkWindowsApp;
          wine = pkgs.wineWowPackages.full; 
        };

        mkwindowsapp-tools = callPackage ./pkgs/mkwindowsapp-tools {};
    };

    packages.aarch64-linux = let
      pkgs = import "${nixpkgs}" {
        system = "aarch64-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
      hsCallPackage = pkgs.haskellPackages.callPackage;
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
      pkgs = import "${nixpkgs}" {
        system = "i686-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
      hsCallPackage = pkgs.haskellPackages.callPackage;
      mkWindowsApp = callPackage ./pkgs/mkWindowsApp.nix { makeBinPath = pkgs.lib.makeBinPath; };
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
        mkwindowsapp-tools = callPackage ./pkgs/mkwindowsapp-tools {};

        notepad-plus-plus = callPackage ./pkgs/notepad++.nix { 
          inherit mkWindowsApp;
          wine = pkgs.wine; 
          wineArch = "win32";
        };
    };

    nixosModules.electrum-personal-server = import ./modules/electrum-personal-server.nix;
    nixosModules.protonvpn = import ./modules/protonvpn.nix;
    nixosModules.btrbk = import ./modules/btrbk.nix;
  };
}
