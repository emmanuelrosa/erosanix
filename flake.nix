{
  description = "Emmanuel's NixOS/Nix Flakes repository.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-compat }: {

    lib.x86_64-linux = let
      pkgs = import "${nixpkgs}" {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
    in {
      mkWindowsApp = callPackage ./pkgs/mkwindowsapp { 
        makeBinPath = pkgs.lib.makeBinPath; 
      };

      copyDesktopIcons = pkgs.makeSetupHook { name = "copyDesktopIcons"; } ./hooks/copy-desktop-icons.sh;
      makeDesktopIcon = callPackage ./lib/makeDesktopIcon.nix {};

      genericBinWrapper = callPackage ./lib/generic-bin-wrapper.nix { };
      nvidia-offload-wrapper = callPackage ./lib/nvidia-offload-wrapper.nix { 
        genericBinWrapper = self.lib.x86_64-linux.genericBinWrapper;
        nvidia-offload = self.packages.x86_64-linux.nvidia-offload;
      };
    };

    lib.i686-linux = let
      pkgs = import "${nixpkgs}" {
        system = "i686-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
    in {
      mkWindowsApp = callPackage ./pkgs/mkwindowsapp { 
        makeBinPath = pkgs.lib.makeBinPath; 
      };

      copyDesktopIcons = pkgs.makeSetupHook { name = "copyDesktopIcons"; } ./hooks/copy-desktop-icons.sh;
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
      in {
        nvidia-offload = callPackage ./pkgs/nvidia-offload.nix {};
        er-wallpaper = hsCallPackage ./pkgs/er-wallpaper.nix { };

        notepad-plus-plus = callPackage ./pkgs/notepad++.nix { 
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wineWowPackages.full; 
          wineArch = "win64";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        sierrachart = callPackage ./pkgs/sierrachart { 
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wine64Packages.stableFull; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        sierrachart-example-study = pkgs.pkgsCross.mingwW64.callPackage ./pkgs/sierrachart/example-study.nix { 
          mcfgthread = pkgs.pkgsCross.mingwW64.windows.mcfgthreads;
          sierrachart = self.packages.x86_64-linux.sierrachart;
        };

        # This is to demonstrate how to install an instance of Sierra Chart using a Nix package to install a study.
        sierrachart-with-example-study = self.packages.x86_64-linux.sierrachart.override { 
          instanceName = "example-study";
          studies = [ self.packages.x86_64-linux.sierrachart-example-study ]; 
        };

        amazon-kindle = callPackage ./pkgs/amazon-kindle { 
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wineWowPackages.full; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        send-to-kindle = callPackage ./pkgs/send-to-kindle.nix { 
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wineWowPackages.full; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
          zenity = pkgs.gnome.zenity;
        };

        vim-desktop = callPackage ./pkgs/vim-desktop.nix {
          makeDesktopIcon = lib.makeDesktopIcon;
          copyDesktopIcons = lib.copyDesktopIcons;
        };

        mkwindowsapp-tools = callPackage ./pkgs/mkwindowsapp-tools { wrapProgram = pkgs.wrapProgram; };

        foobar2000 = callPackage ./pkgs/foobar2000.nix {
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wine64Packages.stableFull; 
          wineArch = "win64";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        roblox = callPackage ./pkgs/roblox/default.nix {
          inherit (lib) mkWindowsApp copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wineWowPackages.full;
          wineArch = "win64";
          rbxfpsunlocker = self.packages.x86_64-linux.rbxfpsunlocker;
        };

        rbxfpsunlocker = callPackage ./pkgs/rbxfpsunlocker.nix { };

        rtrader-pro = callPackage ./pkgs/rtrader/rtrader-pro.nix {
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wineWowPackages.full;
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        line = callPackage ./pkgs/line.nix {
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.wineWowPackages.full; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        sable = callPackage ./pkgs/sable/default.nix { 
          inherit (lib) mkWindowsApp copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.gnome.zenity;
        };

        lego-builders-journey = callPackage ./pkgs/lego-builders-journey/default.nix { 
          inherit (lib) mkWindowsApp makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wine64Packages.stableFull;
          zenity = pkgs.gnome.zenity;
        };

        qutebrowser-hardware-accelerated = let
          wrapper = pkgs.writeShellScript "qutebrowser-hardware-accelerated" ''
            "@EXECUTABLE@" --qt-flag ignore-gpu-backlist --qt-flag enable-gpu-rasterization --qt-flag enable-native-gpu-memory-buffers --qt-flag enable-accelerated-video-decode "$@"
          '';
        in self.lib.x86_64-linux.genericBinWrapper pkgs.qutebrowser wrapper;

        duskers = callPackage ./pkgs/duskers/default.nix { 
          inherit (lib) mkWindowsApp makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wineWowPackages.stableFull;
          zenity = pkgs.gnome.zenity;
        };

        caustic = callPackage ./pkgs/caustic/default.nix {
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.winePackages.stableFull; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        chess-ultra = callPackage ./pkgs/chess-ultra/default.nix {
          inherit (lib) mkWindowsApp makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.gnome.zenity;
        };

        tunche = callPackage ./pkgs/tunche/default.nix {
          inherit (lib) mkWindowsApp makeDesktopIcon copyDesktopIcons;
          wine = pkgs.wine64Packages.stableFull; 
          zenity = pkgs.gnome.zenity;
        };

        specter-desktop = callPackage ./pkgs/specter-desktop/default.nix {
          inherit (lib) makeDesktopIcon copyDesktopIcons;
        };

        blockstream-green = callPackage ./pkgs/blockstream-green/default.nix { };
    } // (builtins.mapAttrs (name: pkg: callPackage pkg { }) (import ./cross-platform-pkgs.nix));

    packages.aarch64-linux = let
      pkgs = import "${nixpkgs}" {
        system = "aarch64-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
      hsCallPackage = pkgs.haskellPackages.callPackage;
      in {
        er-wallpaper = hsCallPackage ./pkgs/er-wallpaper.nix { };
    } // (builtins.mapAttrs (name: pkg: callPackage pkg { }) (import ./cross-platform-pkgs.nix));

    packages.i686-linux = let
      pkgs = import "${nixpkgs}" {
        system = "i686-linux";
        config.allowUnfree = true;
      };

      callPackage = pkgs.callPackage;
      hsCallPackage = pkgs.haskellPackages.callPackage;
      lib = self.lib.i686-linux;
      in {
        er-wallpaper = hsCallPackage ./pkgs/er-wallpaper.nix { };
        mkwindowsapp-tools = callPackage ./pkgs/mkwindowsapp-tools { wrapProgram = pkgs.wrapProgram; };

        notepad-plus-plus = callPackage ./pkgs/notepad++.nix { 
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.winePackages.stableFull; 
          wineArch = "win32";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        vim-desktop = callPackage ./pkgs/vim-desktop.nix {
          makeDesktopIcon = lib.makeDesktopIcon;
          copyDesktopIcons = lib.copyDesktopIcons;
        };

        foobar2000 = callPackage ./pkgs/foobar2000.nix {
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.winePackages.stableFull; 
          wineArch = "win32";
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        caustic = callPackage ./pkgs/caustic/default.nix {
          mkWindowsApp = lib.mkWindowsApp;
          wine = pkgs.winePackages.stableFull; 
          copyDesktopIcons = lib.copyDesktopIcons;
          makeDesktopIcon = lib.makeDesktopIcon;
        };

        roblox = callPackage ./pkgs/roblox/default.nix {
          inherit (lib) mkWindowsApp copyDesktopIcons makeDesktopIcon;
          wine = pkgs.winePackages.stableFull;
          wineArch = "win32";
          rbxfpsunlocker = null;
        };

    } // (builtins.mapAttrs (name: pkg: callPackage pkg { }) (import ./cross-platform-pkgs.nix));

    nixosModules.electrum-personal-server = import ./modules/electrum-personal-server.nix;
    nixosModules.protonvpn = import ./modules/protonvpn.nix;
    nixosModules.btrbk = import ./modules/btrbk.nix;
    nixosModules.matrix-sendmail = import ./modules/matrix-sendmail.nix;
    nixosModules.electrs = import ./modules/electrs.nix;
    nixosModules.fzf = import ./modules/fzf.nix;
    nixosModules.mkwindowsapp-gc = import ./modules/mkwindowsapp-gc.nix;
    nixosModules.sendtome = import ./modules/sendtome.nix;
    nixosModules.onlyoffice = import ./modules/onlyoffice.nix;

    bundlers.x86_64-linux = let
      pkgs = import "${nixpkgs}" {
        system = "x86_64-linux";
      };
    in {
      nvidia-offload = import ./lib/nvidia-offload-wrapper.nix { 
        genericBinWrapper = import ./lib/generic-bin-wrapper.nix { stdenv = pkgs.stdenv; };
        writeShellScript = pkgs.writeShellScript;
        nvidia-offload = self.packages.x86_64-linux.nvidia-offload;
      };
    };
  };
}
