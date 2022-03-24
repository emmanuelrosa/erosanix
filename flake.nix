{
  description = "Emmanuel's NixOS/Nix Flakes repository.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";

  outputs = { self, nixpkgs }: {

    lib.x86_64-linux = let
      pkgs = import "${nixpkgs}" {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
    in {
      mkWindowsApp = callPackage ./pkgs/mkwindowsapp { makeBinPath = pkgs.lib.makeBinPath; };
      copyDesktopIcons = pkgs.makeSetupHook {} ./hooks/copy-desktop-icons.sh;
      makeDesktopIcon = callPackage ./lib/makeDesktopIcon.nix {};

      nvidia-offload-wrapper = callPackage ./lib/nvidia-offload-wrapper.nix { 
        nvidia-offload = self.packages.x86_64-linux.nvidia-offload;
      };
    };

    lib.i686-linux = let
      pkgs = import "${nixpkgs}" {
        system = "i686-linux";
      };

      callPackage = pkgs.callPackage;
    in {
      mkWindowsApp = callPackage ./pkgs/mkwindowsapp { makeBinPath = pkgs.lib.makeBinPath; };
      copyDesktopIcons = pkgs.makeSetupHook {} ./hooks/copy-desktop-icons.sh;
      makeDesktopIcon = callPackage ./lib/makeDesktopIcon.nix {};
    };

    packages.x86_64-linux = let
      pkgs = import "${nixpkgs}" {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
      lib = self.lib.x86_64-linux;
      hsCallPackage = pkgs.haskellPackages.callPackage;
      in rec {
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
        openimajgrabber = callPackage ./pkgs/openimajgrabber.nix {};

        sparrow = callPackage ./pkgs/sparrow.nix { 
          inherit openimajgrabber;

          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        muun-recovery-tool = callPackage ./pkgs/muun-recovery-tool.nix {};

        tastyworks = callPackage ./pkgs/tastyworks.nix {
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        notepad-plus-plus = callPackage ./pkgs/notepad++.nix { 
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wineWowPackages.full; 
          wineArch = "win64";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        sierrachart = callPackage ./pkgs/sierrachart { 
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wineWowPackages.full; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        amazon-kindle = pkgs.lib.trivial.warn "The amazon-kindle package highly unpredictable. I don't recommend using it at this time." (callPackage ./pkgs/amazon-kindle { 
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wineWowPackages.full; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        });

        vim-desktop = callPackage ./pkgs/vim-desktop.nix {
          makeDesktopIcon = lib.makeDesktopIcon;
          copyDesktopIcons = lib.copyDesktopIcons;
        };

        mkwindowsapp-tools = callPackage ./pkgs/mkwindowsapp-tools { wrapProgram = pkgs.wrapProgram; };
        matrix-sendmail = callPackage ./pkgs/matrix-sendmail.nix { };
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
        matrix-sendmail = callPackage ./pkgs/matrix-sendmail.nix { };
    };

    packages.i686-linux = let
      pkgs = import "${nixpkgs}" {
        system = "i686-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
      hsCallPackage = pkgs.haskellPackages.callPackage;
      lib = self.lib.i686-linux;
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
        mkwindowsapp-tools = callPackage ./pkgs/mkwindowsapp-tools { wrapProgram = pkgs.wrapProgram; };

        notepad-plus-plus = callPackage ./pkgs/notepad++.nix { 
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wine; 
          wineArch = "win32";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        vim-desktop = callPackage ./pkgs/vim-desktop.nix {
          makeDesktopIcon = lib.makeDesktopIcon;
          copyDesktopIcons = lib.copyDesktopIcons;
        };

        matrix-sendmail = callPackage ./pkgs/matrix-sendmail.nix { };
    };

    nixosModules.electrum-personal-server = import ./modules/electrum-personal-server.nix;
    nixosModules.protonvpn = import ./modules/protonvpn.nix;
    nixosModules.btrbk = import ./modules/btrbk.nix;
    nixosModules.matrix-sendmail = import ./modules/matrix-sendmail.nix;
    nixosModules.electrs = import ./modules/electrs.nix;
  };
}
